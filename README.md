# Laboratory Work 4 — BreathMotion Guide

Магдич Ольга Валентинівна, ЕАІ-244. Варіант №23: дихально-рухові вправи, інтерфейс camera.

Це окремий репозиторій для реального виконання GitHub Actions за п. 2.2–2.4 методички.
Node.js 24 / JavaScript; PostgreSQL 16; SQLFluff 4.4.0; Biome 2.6.7.

## Запуски

1. Push запускає три workflows для основних файлів.
2. Actions → DataSchemaCodeConvention → Run workflow: вибрати DataSchemaModified.sql для навмисно невдалого SQL-експерименту.
3. Actions → ProgramCodeConvention → Run workflow: вибрати ProgramCodeModified.js для навмисно невдалого JavaScript-експерименту.

Правильні файли мають проходити перевірку. Modified-файли мають завершувати відповідні jobs помилкою. Помилки не приховуються через continue-on-error або `|| true`.

Схема використовує PostgreSQL, тому SQLFluff запускається з `--dialect postgres`, а не oracle з демонстраційного прикладу викладача.

Встановлення: `npm ci` і `python -m pip install -r requirements.txt`. Запуск програми: `npm start`. Перевірка: `npm run check`; SQL: `python -m sqlfluff lint DataSchema.sql --dialect postgres`.
