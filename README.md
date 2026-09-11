# Task Manager

## نبذة عن المشروع

Task Manager هو نظام مبسط لإدارة المشاريع والمهام، يهدف إلى محاكاة لوحة Kanban ومتابعة دورة العمل من إنشاء المشروع والمهام حتى تغيير حالتها وإنجازها.

المشروع تم تطويره باستخدام Flutter للواجهة الأمامية، وNode.js وExpress.js للـBackend، وSQL Server لتخزين البيانات.

## التقنيات المستخدمة

- Flutter / Dart
- Node.js
- Express.js
- Microsoft SQL Server
- Git / GitHub
- Jira لإدارة المهام وتتبع التقدم

## أهم وظائف النظام

### إدارة المشاريع
يمكن إنشاء مشروع جديد مع:
- اسم المشروع
- وصف المشروع
- تاريخ البداية
- تاريخ النهاية المتوقعة

### إدارة المهام
كل مهمة تحتوي على:
- العنوان
- الوصف
- الأولوية: High / Medium / Low
- الحالة: New / In Progress / Done
- المشروع المرتبطة به
- العضو المسؤول عنها

### المهام الرئيسية والفرعية
يدعم النظام إنشاء مهمة رئيسية وربط مهام فرعية بها باستخدام العلاقة الذاتية في جدول `Tasks` من خلال الحقل `parent_task_id`.

### توزيع المهام
يمكن تعيين المهمة أو المهمة الفرعية إلى مستخدم مسجل في النظام.

### Kanban Board
يعرض النظام المهام ضمن ثلاث حالات أساسية:
- New
- In Progress
- Done

ويمكن نقل المهمة بين الحالات من خلال لوحة Kanban.

### Activity Log
يتم تسجيل تغييرات حالة المهمة مع:
- الحالة القديمة
- الحالة الجديدة
- المستخدم الذي قام بالتغيير
- تاريخ ووقت التغيير

### تقرير الإنجاز
يعرض التقرير:
- إجمالي عدد المهام
- عدد المهام المنجزة لكل عضو
- نسبة الإنجاز الكلية للمشروع

## بنية قاعدة البيانات

### USERS
- `id` — PK
- `name`
- `email`
- `password_hash`
- `role`

### PROJECTS
- `id` — PK
- `name`
- `description`
- `start_date`
- `end_date`
- `created_by` — FK → `USERS.id`

### TASKS
- `id` — PK
- `project_id` — FK → `PROJECTS.id`
- `parent_task_id` — FK → `TASKS.id`
- `title`
- `description`
- `priority`
- `status`
- `assigned_to` — FK → `USERS.id`

### ACTIVITY_LOG
- `id` — PK
- `task_id` — FK → `TASKS.id`
- `changed_by` — FK → `USERS.id`
- `old_status`
- `new_status`
- `changed_at`

## العلاقات بين الجداول

- `USERS 1:N PROJECTS` بواسطة `PROJECTS.created_by`
- `PROJECTS 1:N TASKS` بواسطة `TASKS.project_id`
- `USERS 1:N TASKS` بواسطة `TASKS.assigned_to`
- `TASKS 1:N TASKS` بواسطة `TASKS.parent_task_id`
- `TASKS 1:N ACTIVITY_LOG` بواسطة `ACTIVITY_LOG.task_id`
- `USERS 1:N ACTIVITY_LOG` بواسطة `ACTIVITY_LOG.changed_by`

## تشغيل المشروع

### تشغيل Backend

افتح الطرفية داخل مجلد الـBackend ثم:

```bash
npm install
node server.js
```

بعد نجاح التشغيل يجب أن يعمل الخادم على:

```text
http://localhost:3000
```

### تشغيل Flutter

من مجلد مشروع Flutter:

```bash
flutter pub get
flutter run
```

لتشغيل التطبيق على Chrome يمكن استخدام:

```bash
flutter run -d chrome
```

## إدارة الإصدارات

تم تنظيم العمل باستخدام Git وGitHub من خلال:

```text
feature/* → dev → main
```

تم استخدام فروع الميزات لتطوير الأجزاء المختلفة من المشروع، ثم دمجها في `dev` وبعد الاختبار إلى `main`.

أمثلة على فروع الميزات المستخدمة:

- `feature/backend-setup`
- `feature/frontend-ui`
- `feature/current-user`
- `feature/documentation`

## إدارة المشروع باستخدام Jira

تم تقسيم المشروع في Jira إلى مراحل رئيسية:

1. تحليل وتصميم المشروع
2. قاعدة البيانات
3. Backend
4. Flutter Frontend
5. الاختبار والتوثيق

وتم تنظيم المهام باستخدام الأولويات والحالات والتواريخ.

## الاختبار

تم اختبار الوظائف الأساسية للنظام، ومنها:
- إنشاء المشاريع
- إنشاء المهام
- تعيين المستخدمين
- المهام الرئيسية والفرعية
- تغيير الحالة في Kanban
- Activity Log
- التقرير
- تعديل وحذف المهام

كما تم التحقق من سلامة كود Flutter باستخدام:

```bash
flutter analyze
```

## المتطلبات

- Flutter SDK
- Dart
- Node.js
- npm
- Microsoft SQL Server
- Git

## ملاحظات

هذا المشروع تم تنفيذه ضمن مقرر إدارة المشاريع البرمجية بهدف تطبيق مفاهيم تحليل المتطلبات، تصميم قاعدة البيانات، تطوير النظام، إدارة الإصدارات، وتتبع العمل باستخدام Jira وGitHub.
