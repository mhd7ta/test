require('dotenv').config();
const express = require('express');
const cors = require('cors');
const sql = require('mssql');

const app = express();
app.use(cors());
app.use(express.json());

const dbConfig = {
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT),
  options: {
    encrypt: false,
    trustServerCertificate: true
  }
};

let pool;

async function connectDB() {
  try {
    pool = await sql.connect(dbConfig);
    console.log('تم الاتصال بقاعدة البيانات بنجاح');
  } catch (err) {
    console.error('فشل الاتصال بقاعدة البيانات:', err.message);
  }
}

connectDB();

// endpoint تجريبي: جلب كل المستخدمين
app.get('/api/users', async (req, res) => {
  try {
    const result = await pool.request().query('SELECT id, name, email, role FROM Users');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// endpoint تجريبي: إضافة مستخدم جديد (يستخدم Prepared Statement)
app.post('/api/users', async (req, res) => {
  const { name, email, password_hash, role } = req.body;
  try {
    await pool.request()
      .input('name', sql.NVarChar, name)
      .input('email', sql.NVarChar, email)
      .input('password_hash', sql.NVarChar, password_hash)
      .input('role', sql.NVarChar, role || 'member')
      .query(`INSERT INTO Users (name, email, password_hash, role)
              VALUES (@name, @email, @password_hash, @role)`);
    res.status(201).json({ message: 'تمت إضافة المستخدم' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ==================== TASKS ====================

// جلب جميع المهام
app.get('/api/tasks', async (req, res) => {
  try {
    const result = await pool.request().query(`
      SELECT
        id,
        project_id,
        parent_task_id,
        title,
        description,
        priority,
        status,
        assigned_to,
        created_at,
        updated_at
      FROM Tasks
      ORDER BY id DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// إضافة مهمة جديدة
app.post('/api/tasks', async (req, res) => {
  const {
    project_id,
    parent_task_id,
    title,
    description,
    priority,
    status,
    assigned_to
  } = req.body;

  try {
    const result = await pool.request()
      .input('project_id', sql.Int, project_id)
      .input('parent_task_id', sql.Int, parent_task_id || null)
      .input('title', sql.NVarChar(200), title)
      .input('description', sql.NVarChar(sql.MAX), description || null)
      .input('priority', sql.NVarChar(20), priority || 'medium')
      .input('status', sql.NVarChar(30), status || 'new')
      .input('assigned_to', sql.Int, assigned_to || null)
      .query(`
        INSERT INTO Tasks
          (project_id, parent_task_id, title, description,
           priority, status, assigned_to)
        OUTPUT INSERTED.*
        VALUES
          (@project_id, @parent_task_id, @title, @description,
           @priority, @status, @assigned_to)
      `);

    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/tasks/:id/status', async (req, res) => {
  const { id } = req.params;
  const { status, changed_by } = req.body;

  try {
    // جلب الحالة الحالية
    const oldTask = await pool.request()
      .input('id', sql.Int, id)
      .query(`
        SELECT id, status
        FROM Tasks
        WHERE id = @id
      `);

    if (oldTask.recordset.length === 0) {
      return res.status(404).json({
        error: 'المهمة غير موجودة'
      });
    }

    const oldStatus = oldTask.recordset[0].status;

    // تحديث حالة المهمة
    const result = await pool.request()
      .input('id', sql.Int, id)
      .input('status', sql.NVarChar(30), status)
      .query(`
        UPDATE Tasks
        SET status = @status,
            updated_at = GETDATE()
        OUTPUT INSERTED.*
        WHERE id = @id
      `);

    // تسجيل التغيير في ActivityLog
    await pool.request()
  .input('task_id', sql.Int, id)
  .input('old_status', sql.NVarChar(30), oldStatus)
  .input('new_status', sql.NVarChar(30), status)
  .input('changed_by', sql.Int, changed_by)
  .query(`
    INSERT INTO ActivityLog
      (task_id, old_status, new_status, changed_by, changed_at)
    VALUES
      (@task_id, @old_status, @new_status, @changed_by, GETDATE())
  `);

    res.json(result.recordset[0]);

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});



// ==================== PROJECTS ====================

// جلب جميع المشاريع
app.get('/api/projects', async (req, res) => {
  try {
    const result = await pool.request().query(`
      SELECT id, name, description, start_date, end_date, created_by, created_at
      FROM Projects
      ORDER BY id DESC
    `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});


// إضافة مشروع جديد
app.post('/api/projects', async (req, res) => {
  const {
    name,
    description,
    start_date,
    end_date,
    created_by
  } = req.body;

  try {
    const result = await pool.request()
      .input('name', sql.NVarChar(150), name)
      .input('description', sql.NVarChar(sql.MAX), description || null)
      .input('start_date', sql.Date, start_date || null)
      .input('end_date', sql.Date, end_date || null)
      .input('created_by', sql.Int, created_by)
      .query(`
        INSERT INTO Projects
          (name, description, start_date, end_date, created_by)
        OUTPUT INSERTED.*
        VALUES
          (@name, @description, @start_date, @end_date, @created_by)
      `);

    res.status(201).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});
app.get('/api/projects/:id/report', async (req, res) => {
  const projectId = parseInt(req.params.id);

  try {
    // إجمالي المهام ونسبة الإنجاز
    const totalResult = await pool.request()
      .input('project_id', sql.Int, projectId)
      .query(`
        SELECT
          COUNT(*) AS total_tasks,
          SUM(CASE WHEN status = 'done' THEN 1 ELSE 0 END) AS completed_tasks
        FROM Tasks
        WHERE project_id = @project_id
      `);

    const totalTasks = totalResult.recordset[0].total_tasks;
    const completedTasks = totalResult.recordset[0].completed_tasks || 0;

    const completionPercentage = totalTasks > 0
      ? Math.round((completedTasks / totalTasks) * 100)
      : 0;

    // المهام المكتملة لكل عضو
    const membersResult = await pool.request()
      .input('project_id', sql.Int, projectId)
      .query(`
        SELECT
          Users.name AS member_name,
          COUNT(Tasks.id) AS completed_tasks
        FROM Users
        LEFT JOIN Tasks
          ON Users.id = Tasks.assigned_to
          AND Tasks.project_id = @project_id
          AND Tasks.status = 'done'
        GROUP BY Users.id, Users.name
        ORDER BY Users.name
      `);

    res.json({
      total_tasks: totalTasks,
      completed_tasks: completedTasks,
      completion_percentage: completionPercentage,
      completed_per_member: membersResult.recordset
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});

app.get('/api/projects/:id/activity-log', async (req, res) => {
  const projectId = parseInt(req.params.id);

  try {
    const result = await pool.request()
      .input('project_id', sql.Int, projectId)
      .query(`
        SELECT
          ActivityLog.id,
          ActivityLog.task_id,
          Tasks.title AS task_title,
          ActivityLog.old_status,
          ActivityLog.new_status,
          Users.name AS changed_by_name,
          ActivityLog.changed_at
        FROM ActivityLog
        INNER JOIN Tasks
          ON ActivityLog.task_id = Tasks.id
        LEFT JOIN Users
          ON ActivityLog.changed_by = Users.id
        WHERE Tasks.project_id = @project_id
        ORDER BY ActivityLog.changed_at DESC
      `);

    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});
app.delete('/api/tasks/:id', async (req, res) => {
  const { id } = req.params;

  try {
    // حذف سجل النشاط المرتبط بالمهمة أولاً
    await pool.request()
      .input('task_id', sql.Int, id)
      .query(`
        DELETE FROM ActivityLog
        WHERE task_id = @task_id
      `);

    // حذف المهمة
    const result = await pool.request()
      .input('id', sql.Int, id)
      .query(`
        DELETE FROM Tasks
        WHERE id = @id
      `);

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({
        error: 'المهمة غير موجودة'
      });
    }

    res.json({
      message: 'تم حذف المهمة بنجاح'
    });

  } catch (err) {
    res.status(500).json({
      error: err.message
    });
  }
});

// تعديل عام لمهمة (عنوان، وصف، أولوية، توزيع، أو نقلها تحت مهمة رئيسية تانية)
app.put('/api/tasks/:id', async (req, res) => {
  const { id } = req.params;
  const { title, description, priority, assigned_to, parent_task_id } = req.body;

  try {
    const result = await pool.request()
      .input('id', sql.Int, id)
      .input('title', sql.NVarChar(200), title)
      .input('description', sql.NVarChar(sql.MAX), description || null)
      .input('priority', sql.NVarChar(20), priority || 'medium')
      .input('assigned_to', sql.Int, assigned_to || null)
      .input('parent_task_id', sql.Int, parent_task_id || null)
      .query(`
        UPDATE Tasks
        SET
          title = @title,
          description = @description,
          priority = @priority,
          assigned_to = @assigned_to,
          parent_task_id = @parent_task_id,
          updated_at = GETDATE()
        OUTPUT INSERTED.*
        WHERE id = @id
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'المهمة غير موجودة' });
    }

    res.json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`السيرفر شغال على http://localhost:${PORT}`);
});