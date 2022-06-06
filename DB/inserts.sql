-- account
-- chat
-- entity -> notifiable
-- group -> entity -> notifiable
-- message -> notifiable
-- event -> entity -> notifiable
-- post -> entity -> notifiable
-- media -> post -> entity -> notifiable
-- comment -> post -> entity -> notifiable
-- share -> post -> entity -> notifiable
-- user -> account
-- page -> account
-- react -> notifiable
-- account_relationship -> notifiable
-- user_page_relationship -> notifiable
-- notification
-- conversation -> chat
-- group_chat -> chat
-- member
-- event_participant
-- visibility_user_set
-- group_member
-- notifiable

CREATE OR REPLACE PACKAGE BODY inserts AS
    FUNCTION account_insert
    (
        account_kind NUMBER
    ) RETURN NUMBER
        IS
        new_id NUMBER(19) := account_seq.NEXTVAL;
    BEGIN
        INSERT
        INTO
            account
        (
            id, kind
        )
        VALUES
            (
                new_id, account_kind
            );
        RETURN new_id;
    END;
    FUNCTION account_insert
    (
        table_name VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN account_insert(enums.table_kind(table_name));
    END;
    FUNCTION notifiable_insert
    (
        table_name VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN notifiable_insert(enums.table_kind(table_name));
    END;
    FUNCTION entity_insert
    (
          entity_owner      NUMBER
        , entity_visibility NUMBER
        , entity_kind       NUMBER
    ) RETURN NUMBER
        IS
        NEW_ENTITY_ID NUMBER(19);
    BEGIN
        NEW_ENTITY_ID := notifiable_insert(entity_kind);
        INSERT
        INTO
            entity
        (
            id, owner_id, time_created, visibility, active, kind
        )
        VALUES
            (
                NEW_ENTITY_ID, entity_owner, SYSDATE, entity_visibility, 1, entity_kind
            );
        RETURN NEW_ENTITY_ID;
    END;
    FUNCTION entity_insert
    (
          entity_owner      NUMBER
        , entity_visibility VARCHAR2
        , entity_kind       VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN entity_insert(
                entity_owner
            , enums.visibility(entity_visibility)
            , enums.table_kind(entity_kind)
            );
    END;
    FUNCTION notifiable_insert
    (
        notifiable_kind NUMBER
    ) RETURN NUMBER
        IS
        new_id NUMBER(19) := notifiable_seq.NEXTVAL;
    BEGIN
        INSERT
        INTO
            notifiable
        (
            id, kind
        )
        VALUES
            (
                new_id, notifiable_kind
            );
        RETURN new_id;
    END;
    FUNCTION notification_insert
    (
          user_id_value NUMBER
        , type_value    VARCHAR2
        , item_id_value NUMBER
    ) RETURN NUMBER
        IS
        notification_id NUMBER(19);
    BEGIN
        notification_id := notifications_seq.NEXTVAL;
        INSERT
        INTO
            notification
        (
            id, account_id, "TYPE", item_id, time_created
        )
        VALUES
            (
                notification_id, user_id_value, type_value, item_id_value, SYSDATE
            );
        RETURN notification_id;
    END;
    FUNCTION chat_insert
    (
        chat_kind NUMBER
    ) RETURN NUMBER
        IS
        chat_id NUMBER(19);
    BEGIN
        chat_id := chat_seq.nextval;
        INSERT
        INTO
            chat
        (
            id, kind
        )
        VALUES
            (
                chat_id, chat_kind
            );
        RETURN chat_id;
    END;
    FUNCTION chat_insert
    (
        chat_kind VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN chat_insert(enums.table_kind(chat_kind));
    END;
    FUNCTION event_insert
    (
          event_timing     DATE
        , event_owner      NUMBER
        , event_visibility NUMBER
    ) RETURN NUMBER
        IS
        entity_id NUMBER;
    BEGIN
        entity_id := entity_insert(event_owner, event_visibility, enums.table_kind('event'));
        INSERT
        INTO
            event
        (
            id, timing
        )
        VALUES
            (
                entity_id, event_timing
            );
        notify_about_entity('new event', entity_id);
        RETURN entity_id;
    END;
    FUNCTION event_insert
    (
          event_timing     DATE
        , event_owner      NUMBER
        , event_visibility VARCHAR2
    ) RETURN NUMBER
        IS
    BEGIN
        RETURN event_insert(
                event_timing
            , event_owner
            , enums.visibility(event_visibility)
            );
    END;
    FUNCTION user_insert
    (
        user_first_name   VARCHAR2,
        user_middle_name  VARCHAR2,
        user_last_name    VARCHAR2,
        user_username     VARCHAR2,
        user_mobile       NUMBER,
        user_email        VARCHAR2,
        user_passwordHash VARCHAR2,
        user_intro        VARCHAR2,
        user_profile      VARCHAR2
    ) RETURN NUMBER
        IS
        user_id NUMBER(19);
    BEGIN
        user_id := account_insert('user');
        INSERT
        INTO
            "USER"
        (
            id
        ,   first_name
        ,   middle_name
        ,   last_name
        ,   username
        ,   mobile
        ,   email
        ,   passwordHash
        ,   registeredAt
        ,   lastLogin
        ,   intro
        ,   profile
        ,   chat_id
        ,   active
        )
        VALUES
            (
                user_id
            ,   user_first_name
            ,   user_middle_name
            ,   user_last_name
            ,   user_username
            ,   user_mobile
            ,   user_email
            ,   user_passwordHash
            ,   SYSDATE
            ,   SYSDATE
            ,   user_intro
            ,   user_profile
            ,   chat_insert('saved_messages')
            ,   1
            );
        RETURN user_id;
    END;
    FUNCTION page_insert
    (
        page_name VARCHAR2
    ) RETURN NUMBER
        IS
        page_id NUMBER(19);
    BEGIN
        page_id := account_insert('page');
        INSERT
        INTO
            page
        (
            id, name
        )
        VALUES
            (
                page_id, page_name
            );
        RETURN page_id;
    END;
    FUNCTION message_insert
    (
        message_from_value NUMBER,
        message_value      VARCHAR2,
        chat_id_value      NUMBER
    ) RETURN NUMBER
        IS
        message_id NUMBER(19);
    BEGIN
        message_id := notifiable_insert('message');
        INSERT
        INTO
            message
        (
            id, message_from, message, viewed, time, chat_id
        )
        VALUES
            (
                message_id, message_from_value, message_value, 'N', SYSDATE, chat_id_value
            );
        notify_about_message(message_id);
        RETURN message_id;
    END;
    FUNCTION post_insert
    (
          text_value      VARCHAR2
        , post_kind       NUMBER
        , post_owner      NUMBER
        , post_visibility NUMBER
    ) RETURN NUMBER
        IS
        post_id NUMBER := entity_insert
                              (post_owner
                              , post_visibility
                              , enums.table_kind('POST'));
    BEGIN
        INSERT
        INTO
            post(
            id, text, kind
                )
        VALUES
            (
                post_id, text_value, post_kind
            );
        notify_about_entity('new post', post_id);
        RETURN post_id;
    END;
    FUNCTION post_insert
    (
          text_value  VARCHAR2
        , post_kind   VARCHAR2
        , post_owner  NUMBER
        , visibility  VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN post_insert(
                text_value
            , enums.table_kind(post_kind)
            , post_owner
            , enums.visibility(visibility));
    END;
    FUNCTION media_insert
    (
          media_path            VARCHAR2
        , text                  VARCHAR2
        , post_owner            NUMBER
        , media_post_visibility number
    ) RETURN NUMBER
        IS
        media_id NUMBER(19);
    BEGIN
        media_id := post_insert(text, enums.table_kind('media'), post_owner, media_post_visibility);
        INSERT
        INTO
            media
        (
            id, path
        )
        VALUES
            (
                media_id, media_path
            );
        RETURN media_id;
    END;
    FUNCTION media_insert
    (
          media_path            VARCHAR2
        , text                  VARCHAR2
        , post_owner            NUMBER
        , media_post_visibility VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN media_insert(
                media_path
            , text
            , post_owner
            , enums.visibility(media_post_visibility)
            );
    END;
    FUNCTION share_insert
    (
          post_id_value NUMBER
        , text          VARCHAR2
        , share_owner   NUMBER
        , visibility    NUMBER
    ) RETURN NUMBER
        IS
        share_id NUMBER(19);
    BEGIN
        share_id := post_insert(
                text
            , enums.table_kind('share')
            , share_owner
            , visibility
            );
        INSERT
        INTO
            "SHARE"
        (
            id, post_id
        )
        VALUES
            (
                share_id, post_id_value
            );
        RETURN share_id;
    END;
    FUNCTION share_insert
    (
          post_id_value    NUMBER
        , text             VARCHAR2
        , share_owner      NUMBER
        , share_visibility VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN share_insert(
                post_id_value
            , text
            , share_owner
            , enums.visibility(share_visibility)
            );
    END;
    FUNCTION comment_insert
    (
          post_id_value      NUMBER
        , text               VARCHAR2
        , comment_owner      NUMBER
        , comment_visibility NUMBER
    ) RETURN NUMBER
        IS
        comment_id NUMBER(19);
    BEGIN
        comment_id := post_insert(
                text,
                enums.table_kind('comment'), comment_owner, comment_visibility);
        INSERT
        INTO
            comment
        (
            id, post_id
        )
        VALUES
            (
                comment_id, post_id_value
            );
        RETURN comment_id;
    END;
    FUNCTION comment_insert
    (
          comment_post_id    NUMBER
        , text               VARCHAR2
        , comment_owner      NUMBER
        , comment_visibility VARCHAR2
    ) RETURN NUMBER IS
    BEGIN
        RETURN comment_insert(
                comment_post_id
            , text
            , comment_owner
            , enums.visibility(comment_visibility)
            );
    END;
    FUNCTION react_insert
    (
          react_post_id NUMBER
        , react_user_id NUMBER
        , react_type    VARCHAR2
    ) RETURN NUMBER
        IS
        react_id NUMBER(19);
    BEGIN
        react_id := notifiable_insert('react');
        INSERT
        INTO
            react
        (
            id, post_id, user_id, "TYPE"
        )
        VALUES
            (
                react_id, react_post_id, react_user_id, react_type
            );
        notify_about_react(react_id);
        RETURN react_id;
    END;
    FUNCTION account_relationship_insert
    (
          sourceId            NUMBER
        , targetId            NUMBER
        , relationship_type   NUMBER
        , relationship_status NUMBER
        , relationship_notes  VARCHAR2
    ) RETURN NUMBER
        IS
        relationship_id NUMBER(19);
    BEGIN
        relationship_id := notifiable_insert('account_relationship');
        INSERT
        INTO
            account_relationship
        (
            id, source_id, target_id, "TYPE", created, updated, status, notes
        )
        VALUES
            (
                relationship_id
            ,   sourceId
            ,   targetId
            ,   relationship_type
            ,   SYSDATE
            ,   SYSDATE
            ,   relationship_status
            ,   relationship_notes
            );
        notify_about_relationship(relationship_id);
        RETURN relationship_id;
    END;
    FUNCTION group_chat_insert
    (
        group_name VARCHAR2
    ) RETURN NUMBER
        IS
        group_chat_id NUMBER(19);
    BEGIN
        group_chat_id := chat_insert('group_chat_insert');
        INSERT
        INTO
            group_chat
        (
            id, name
        )
        VALUES
            (
                group_chat_id, group_name
            );
        RETURN group_chat_id;
    END;
    FUNCTION member_insert
    (
          accountId       NUMBER
        , group_chatId    NUMBER
        , membership_type VARCHAR2
    ) RETURN NUMBER
        IS
        member_id NUMBER(19);
    BEGIN
        member_id := member_seq.nextval;
        INSERT
        INTO
            member
        (
            id, "TYPE", account_id, group_chat_id
        )
        VALUES
            (
                member_id, membership_type, accountId, group_chatId
            );
        RETURN member_id;
    END;
    FUNCTION event_participant_insert
    (
          eventId NUMBER
        , userId  NUMBER
    ) RETURN NUMBER
        IS
        participant_id NUMBER(19);
    BEGIN
        participant_id := participant_seq.nextval;
        INSERT
        INTO
            event_participant
        (
            id, event_id, user_id
        )
        VALUES
            (
                participant_id, eventId, userId
            );
        RETURN participant_id;
    END;
    FUNCTION visibility_user_list_insert
    (
          entityId NUMBER
        , userId   NUMBER
    ) RETURN NUMBER
        IS
        visibility_user_list_id NUMBER(19);
    BEGIN
        visibility_user_list_id := visibility_user_list_seq.nextval;
        INSERT
        INTO
            visibility_user_set
        (
            id, entity_id, user_id
        )
        VALUES
            (
                visibility_user_list_id, entityId, userId
            );
        RETURN visibility_user_list_id;
    END;
    PROCEDURE notify_x_friends
    (
          x                 NUMBER
        , notification_type VARCHAR2
        , item_id           NUMBER
    ) IS
        created_notification NUMBER(19);
        CURSOR user_pair IS
            SELECT
                da_friend_of_x(source_id, target_id, x) AS id
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
                created_notification := notification_insert(friend.id, notification_type, item_id);
            END LOOP;
    END;
    FUNCTION da_friend_of_x
    (
          user_1 NUMBER
        , user_2 NUMBER
        , x      NUMBER
    ) RETURN NUMBER IS
    BEGIN
        IF (user_1 = x) THEN
            RETURN user_2;
        ELSE
            RETURN user_1;
        END IF;
    END;
    PROCEDURE notify_x_friends_exclude
    (
          x                 NUMBER
        , notification_type VARCHAR2
        , item_id           NUMBER
    ) IS
        created_notification NUMBER(19);
        CURSOR lst IS
            SELECT
                    (SELECT
                         da_friend_of_x(source_id, target_id, x) id
                     FROM
                         entity
                             JOIN "USER"
                                  ON "USER".id = x
                             JOIN account_relationship
                                  ON source_id = x OR target_id = x
                     WHERE
                         entity.id = item_id) - (SELECT
                                                     user_id id
                                                 FROM
                                                     visibility_user_set
                                                 WHERE
                                                     item_id = item_id)
                    id
            FROM
                DUAL;
    BEGIN
        FOR friend IN lst
            LOOP
                created_notification := notification_insert(friend.id, notification_type, item_id);
            END LOOP;
    END;
    PROCEDURE notify_list
    (
          notification_type VARCHAR2
        , itemId            NUMBER
    ) IS
        created_notification NUMBER(19);
        CURSOR lst IS
            SELECT
                user_id as id
            FROM
                visibility_user_set
            WHERE
                entity_id = itemId;
    BEGIN
        FOR friend IN lst
            LOOP
                created_notification := notification_insert(friend.id, notification_type, itemId);
            END LOOP;
    END;
-- Please: Update Visibility list before notifying
    PROCEDURE notify_about_entity
    (
          notification_type VARCHAR2
        , entityId          NUMBER
    ) IS
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
        CASE enums.visibility(entity_visibility)
            WHEN 'public' THEN notify_x_friends(entity_owner_id, notification_type, entityId);
            WHEN 'friends' THEN notify_x_friends(entity_owner_id, notification_type, entityId);
            WHEN 'friends except' THEN notify_x_friends_exclude(entity_owner_id, notification_type, entityId);
            WHEN 'only list' THEN notify_list(notification_type, entityId);
            END CASE;
    END ;

--
    PROCEDURE notify_about_react
    (
        react_id NUMBER
    ) IS
        reacted_to_user_id   NUMBER(19);
        created_notification NUMBER(19);
    BEGIN
        -- Get the account_id of the person who reacted to the post
        SELECT owner_id INTO reacted_to_user_id FROM entity WHERE id = react_id;
        created_notification := notification_insert(reacted_to_user_id, 'react', react_id);
    END;

    PROCEDURE notify_about_message
    (
        message_id NUMBER
    ) IS
        message_from_id       NUMBER(19);
        chat_kind             VARCHAR2(50);
        other_in_conversation NUMBER(19);
        message_chat_id       NUMBER(19);
        CURSOR group_members IS
            SELECT
                account_id AS id
            FROM
                message
                    JOIN member ON message.chat_id = member.group_chat_id
            WHERE
                message.id = message_id;
        created_notification  NUMBER(19);
    BEGIN
        -- Get the kind of the chat
        SELECT
            enums.table_kind(kind)
          , message_from
          , chat_id
        INTO chat_kind,message_from_id, message_chat_id
        FROM
            chat
                JOIN message ON chat.id = message.chat_id
        WHERE
            message.id = message_id;
        CASE chat_kind
            WHEN 'group_chat' THEN FOR group_member IN group_members
                LOOP
                    created_notification := notification_insert(group_member.id, 'message', message_id);
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
                                     created_notification := notification_insert(
                                             other_in_conversation
                                         , 'message'
                                         , message_id);
            END CASE;
    END;

-- WHEN 'account_relationship' THEN
    PROCEDURE notify_about_relationship
    (
        account_relationship_id NUMBER
    ) IS
        befriended_user_id   NUMBER(19);
        created_notification NUMBER(19);

    BEGIN
        -- Get the account_id of the person who was befriended
        SELECT
            target_id
        INTO befriended_user_id
        FROM
            account_relationship
        WHERE
            id = account_relationship_id;
        created_notification :=
                notification_insert(befriended_user_id, 'account_relationship', account_relationship_id);
    END;

END;
/
CREATE OR REPLACE PACKAGE inserts AS
    FUNCTION account_insert
    (
        account_kind NUMBER
    ) RETURN NUMBER;
    FUNCTION account_insert
    (
        table_name VARCHAR2
    ) RETURN NUMBER ;
    FUNCTION notifiable_insert
    (
        table_name VARCHAR2
    ) RETURN NUMBER ;
    FUNCTION entity_insert
    (
          entity_owner      NUMBER
        , entity_visibility NUMBER
        , entity_kind       NUMBER
    ) RETURN NUMBER;
    FUNCTION entity_insert
    (
          entity_owner      NUMBER
        , entity_visibility VARCHAR2
        , entity_kind       VARCHAR2
    ) RETURN NUMBER;
    FUNCTION notifiable_insert
    (
        notifiable_kind NUMBER
    ) RETURN NUMBER;
    FUNCTION notification_insert
    (
          user_id_value NUMBER
        , type_value    VARCHAR2
        , item_id_value NUMBER
    ) RETURN NUMBER;
    FUNCTION chat_insert
    (
        chat_kind NUMBER
    ) RETURN NUMBER;
    FUNCTION chat_insert
    (
        chat_kind VARCHAR2
    ) RETURN NUMBER ;
    FUNCTION event_insert
    (
          event_timing     DATE
        , event_owner      NUMBER
        , event_visibility NUMBER
    ) RETURN NUMBER;
    FUNCTION event_insert
    (
          event_timing     DATE
        , event_owner      NUMBER
        , event_visibility VARCHAR2
    ) RETURN NUMBER;
    FUNCTION user_insert
    (
        user_first_name   VARCHAR2,
        user_middle_name  VARCHAR2,
        user_last_name    VARCHAR2,
        user_username     VARCHAR2,
        user_mobile       NUMBER,
        user_email        VARCHAR2,
        user_passwordHash VARCHAR2,
        user_intro        VARCHAR2,
        user_profile      VARCHAR2
    ) RETURN NUMBER;
    FUNCTION page_insert
    (
        page_name VARCHAR2
    ) RETURN NUMBER;
    FUNCTION message_insert
    (
        message_from_value NUMBER,
        message_value      VARCHAR2,
        chat_id_value      NUMBER
    ) RETURN NUMBER;
    FUNCTION post_insert
    (
          text_value      VARCHAR2
        , post_kind       NUMBER
        , post_owner      NUMBER
        , post_visibility NUMBER
    ) RETURN NUMBER;
    FUNCTION post_insert
    (
          text_value  VARCHAR2
        , post_kind   VARCHAR2
        , post_owner  NUMBER
        , visibility  VARCHAR2
    ) RETURN NUMBER;
    FUNCTION media_insert
    (
          media_path            VARCHAR2
        , text                  VARCHAR2
        , post_owner            NUMBER
        , media_post_visibility NUMBER
    ) RETURN NUMBER;
    FUNCTION media_insert
    (
          media_path            VARCHAR2
        , text                  VARCHAR2
        , post_owner            NUMBER
        , media_post_visibility VARCHAR2
    ) RETURN NUMBER;
    FUNCTION share_insert
    (
          post_id_value NUMBER
        , text          VARCHAR2
        , share_owner   NUMBER
        , visibility    NUMBER
    ) RETURN NUMBER;
    FUNCTION share_insert
    (
          post_id_value    NUMBER
        , text             VARCHAR2
        , share_owner      NUMBER
        , share_visibility VARCHAR2
    ) RETURN NUMBER;
    FUNCTION comment_insert
    (
          post_id_value      NUMBER
        , text               VARCHAR2
        , comment_owner      NUMBER
        , comment_visibility NUMBER
    ) RETURN NUMBER;
    FUNCTION comment_insert
    (
          comment_post_id    NUMBER
        , text               VARCHAR2
        , comment_owner      NUMBER
        , comment_visibility VARCHAR2
    ) RETURN NUMBER ;
    FUNCTION react_insert
    (
          react_post_id NUMBER
        , react_user_id NUMBER
        , react_type    VARCHAR2
    ) RETURN NUMBER;
    FUNCTION account_relationship_insert
    (
          sourceId            NUMBER
        , targetId            NUMBER
        , relationship_type   NUMBER
        , relationship_status NUMBER
        , relationship_notes  VARCHAR2
    ) RETURN NUMBER;
    FUNCTION group_chat_insert
    (
        group_name VARCHAR2
    ) RETURN NUMBER;
    FUNCTION member_insert
    (
          accountId       NUMBER
        , group_chatId    NUMBER
        , membership_type VARCHAR2
    ) RETURN NUMBER;
    FUNCTION event_participant_insert
    (
          eventId NUMBER
        , userId  NUMBER
    ) RETURN NUMBER;
    FUNCTION visibility_user_list_insert
    (
          entityId NUMBER
        , userId   NUMBER
    ) RETURN NUMBER;
    PROCEDURE notify_x_friends
    (
          x                 NUMBER
        , notification_type VARCHAR2
        , item_id           NUMBER
    );
    PROCEDURE notify_x_friends_exclude
    (
          x                 NUMBER
        , notification_type VARCHAR2
        , item_id           NUMBER
    );
    PROCEDURE notify_list
    (
          notification_type VARCHAR2
        , itemId            NUMBER
    );
    PROCEDURE notify_about_entity
    (
          notification_type VARCHAR2
        , entityId          NUMBER
    );
    PROCEDURE notify_about_react
    (
        react_id NUMBER
    );
    PROCEDURE notify_about_message
    (
        message_id NUMBER
    );
    PROCEDURE notify_about_relationship
    (
        account_relationship_id NUMBER
    );
    FUNCTION da_friend_of_x
    (
          user_1 NUMBER
        , user_2 NUMBER
        , x      NUMBER
    ) RETURN NUMBER;
END;
/

-- FUNCTION [^\)\(]*\([^\)\(]*\) return .*