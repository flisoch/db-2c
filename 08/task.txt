Создать таблицу пользователей user(id, name, email)
    И логов user_log (id, old_user_name, new_user_name, old_email, new_email, date, op_type)
    - сделать триггеры, которые в таблицу добавляют значения
    (date- дата изменения, op_type - тип операции)

Таблица products - (id, name, price),
    таблица sales (id, product_id, new_price, date)
    - сделать триггер, который проверяет, что новая цена меньше старой.
