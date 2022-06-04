CREATE OR REPLACE PROCEDURE notify_x_friends
(
      x                 NUMBER(19)
    , notification_type VARCHAR2(50)
    , item_id           NUMBER(19)
) IS
DECLARE
    CURSOR user_pair IS
        SELECT
            da_friend_of_x(source_id, target_id, x)
        FROM
            entity
                JOIN "USER"
                     ON "USER".id = x
                JOIN account_relationship
                     ON source_id = "USER".id OR target_id = "USER".id
        WHERE
            entity.id = item_id;
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
        SELECT
                (SELECT
                     da_friend_of_x(source_id, target_id, x)
                 FROM
                     entity
                         JOIN "USER"
                              ON "USER".id = x
                         JOIN account_relationship
                              ON source_id = x OR target_id = x
                 WHERE
                     entity.id = item_id) - (SELECT
                                                 user_id
                                             FROM
                                                 visibility_user_set
                                             WHERE
                                                 item_id = item_id)
        FROM
            DUAL;
BEGIN
    FOR friend IN lst
        LOOP
            notification_insert(friend, notification_type, item_id);
        END LOOP;
END;
CREATE OR REPLACE PROCEDURE notify_list
(
      notification_type VARCHAR2(50)
    , itemId            NUMBER(19)
) IS
DECLARE
    CURSOR lst IS
        SELECT
            user_id
        FROM
            visibility_user_set
        WHERE
            entity_id = itemId;
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
    this_entity_kind  VARCHAR2(50);
BEGIN
    SELECT
        owner_id
      , visibility
      , kind
    INTO entity_owner_id, entity_visibility, this_entity_kind
    FROM
        entity
    WHERE
        id = entityId;
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
--
CREATE OR REPLACE PROCEDURE notify_about_react
(
    react_id NUMBER(19)
) IS
DECLARE
    reacted_to_user_id NUMBER(19);
BEGIN
    -- Get the account_id of the person who reacted to the post
    SELECT owner_id INTO reacted_to_user_id FROM entity WHERE id = react_id;
    notification_insert(reacted_to_user_id, 'react', react_id);
END;
CREATE OR REPLACE PROCEDURE notify_about_message
(
    message_id NUMBER(19)
) IS
DECLARE
    message_from_id       NUMBER(19);
    chat_kind             VARCHAR2(50);
    other_in_conversation NUMBER(19);
    message_chat_id       NUMBER(19);
    CURSOR group_members IS
        SELECT
            account_id
        FROM
            message join member on message.chat_id = member.group_chat_id
        WHERE
            message.id = message_id;
BEGIN
    -- Get the kind of the chat
    SELECT
        table_kind(kind)
      , message_from
      , chat_id
    INTO chat_kind,message_from_id, message_chat_id
    FROM
        chat
            JOIN message ON chat.id = message.chat_id
    WHERE
        message.id = message_id;
    CASE chat_kind
        WHEN 'saved_messages' THEN
        --nothing
        WHEN 'group_chat' THEN
            FOR group_member IN group_members
                LOOP
                    notification_insert(group_member, 'message', message_id);
                END LOOP;
        WHEN 'conversation' THEN SELECT
                                     da_friend_of_x(source_id
                                         , target_id, message_from_id)
                                 INTO other_in_conversation
                                 FROM
                                     account_relationship
                                 WHERE
                                       account_relationship.chat_id = message_chat_id
                                   AND (
                                                   source_id = message_from_id
                                               OR target_id = message_from_id);
                                 notification_insert(
                                     other_in_conversation
                                     , 'message'
                                     , message_id);
        END CASE;
END;
-- WHEN 'account_relationship' THEN
CREATE OR REPLACE PROCEDURE notify_about_account_relationship
(
    account_relationship_id NUMBER(19)
) IS
DECLARE
    befriended_user_id NUMBER(19);
begin
    -- Get the account_id of the person who was befriended
    SELECT target_id INTO befriended_user_id
                   FROM account_relationship
                   WHERE id = account_relationship_id;
    notification_insert(befriended_user_id, 'account_relationship', account_relationship_id);
END;