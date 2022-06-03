CREATE OR REPLACE PROCEDURE notify_x_friends
(
      x                 NUMBER(19)
    , notification_type VARCHAR2(50)
    , item_id           NUMBER(19)
) IS
DECLARE
    CURSOR user_pair IS
        SELECT da_friend_of_x(source_id, target_id, x)
        FROM entity
                 JOIN "USER"
                      ON "USER".id = x
                 JOIN account_relationship
                      ON source_id = "USER".id OR target_id = "USER".id
        WHERE entity.id = item_id;
BEGIN
    FOR friend IN user_pair
        LOOP
            notification_insert(friend, notification_type, item_id);
        END LOOP;
END;

CREATE OR REPLACE FUNCTION da_friend_of_x
(
      user_1 NUMBER(19)
    , user_2 NUMBER(19)
    , x      NUMBER(19)
) RETURN NUMBER(19) IS
BEGIN
    IF (user_1 = x) THEN
        RETURN user_2;
    ELSE
        RETURN user_1;
    END IF;
END;
CREATE OR REPLACE PROCEDURE notify_x_friends_exclude
(
      x                 NUMBER(19)
    , notification_type VARCHAR2(50)
    , item_id           NUMBER(19)
) IS
DECLARE
    CURSOR lst IS
        SELECT (SELECT da_friend_of_x(source_id, target_id, x)
                FROM entity
                         JOIN "USER"
                              ON "USER".id = x
                         JOIN account_relationship
                              ON source_id = x OR target_id = x
                WHERE entity.id = item_id) - (SELECT user_id
                                              FROM visibility_user_set
                                              WHERE item_id = item_id)
        FROM DUAL;
BEGIN
    FOR friend IN lst
        LOOP
            notification_insert(friend, notification_type, item_id);
        END LOOP;
END;

CREATE OR REPLACE PROCEDURE notify_list
(
      notification_type VARCHAR2(50)
    , itemId           NUMBER(19)
) IS
DECLARE
    CURSOR lst IS
        SELECT user_id
        FROM visibility_user_set
        WHERE entity_id = itemId;
BEGIN
    FOR friend IN lst
        LOOP
            notification_insert(friend, notification_type, itemId);
        END LOOP;
END;
-- Please: Update Visibility list before notifying
CREATE OR REPLACE PROCEDURE notify_about_entity
(
      notification_type VARCHAR2(50)
    , entityId          NUMBER(19)
) IS
DECLARE
    entity_owner_id   NUMBER(19);
    entity_visibility NUMBER(10);
BEGIN
    SELECT owner_id, visibility
    INTO entity_owner_id, entity_visibility
    FROM entity
    WHERE id = entityId;
    CASE visibility(entity_visibility)
        WHEN 'public' THEN notify_x_friends(entity_owner_id, notification_type, entityId);
        WHEN 'only me' THEN
        --nothing
        WHEN 'friends' THEN notify_x_friends(entity_owner_id, notification_type, entityId);
        WHEN 'friends except' THEN notify_x_friends_exclude(entity_owner_id, notification_type, entityId);
        WHEN 'only list' THEN notify_list(notification_type, entityId);
        ELSE
            --nothing
        END CASE;
END ;