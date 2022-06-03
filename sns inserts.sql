-- account
-- chat
-- entity -> notifiable
-- feed -> entity -> notifiable
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

CREATE OR REPLACE FUNCTION feed_insert
(
      feed_owner_id      NUMBER(19)
    , feed_visibility_id NUMBER(10)
) RETURN NUMBER AS
DECLARE
    entity_id NUMBER(19);
BEGIN
    entity_id := entity_insert(feed_owner_id
        , feed_visibility_id
        , 'feed');
    INSERT
    INTO
        feed
    (id
    )
    VALUES
        (entity_id
        );
    RETURN entity_id;
END;
CREATE OR REPLACE FUNCTION feed_insert
(
      feed_owner_id   NUMBER(19)
    , feed_visibility VARCHAR2
    , table_name      VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN feed_insert(feed_owner_id, feed_visibility, table_kind(table_name));
END;
CREATE OR REPLACE FUNCTION user_insert
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
) RETURN NUMBER AS
DECLARE
    user_id NUMBER(19);
BEGIN
    user_id := chatter_insert('user');
    INSERT
    INTO
        "USER"
    ( id
    , first_name
    , middle_name
    , last_name
    , username
    , mobile
    , email
    , passwordHash
    , registeredAt
    , lastLogin
    , intro
    , profile
    , feed_id
    , chat_id
    )
    VALUES
        ( user_id
        , user_first_name
        , user_middle_name
        , user_last_name
        , user_username
        , user_mobile
        , user_email
        , user_passwordHash
        , SYSDATE
        , SYSDATE
        , user_intro
        , user_profile
        , feed_insert(
                  user_id
              , 'public'
              , 'user'
              )
        , chat_insert('saved_messages')
        );
    RETURN user_id;
END;
CREATE OR REPLACE FUNCTION chat_insert
(
    chat_kind NUMBER(4)
) RETURN NUMBER AS
DECLARE
    chat_id NUMBER(19);
BEGIN
    INSERT
    INTO
        chat
    (id, kind
    )
    VALUES
        (chat_id, chat_kind
        );
    RETURN chat_id;
END;
CREATE OR REPLACE FUNCTION chat_insert
(
    chat_kind VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN chat_insert(table_kind(chat_kind));
END;
CREATE OR REPLACE FUNCTION page_insert RETURN NUMBER AS
DECLARE
    page_id NUMBER(19);
BEGIN
    page_id := chatter_insert('page');
    INSERT
    INTO
        page
    (id, feed_id
    )
    VALUES
        ( page_id
        , feed_insert
              (
                  page_id
              , 'public'
              , 'page'
              )
        );
    RETURN page_id;
END;
CREATE OR REPLACE FUNCTION chatter_insert
(
    chatter_kind NUMBER(4)
) RETURN NUMBER(19) AS
DECLARE
    new_id NUMBER(19) := account_seq.NEXTVAL;
BEGIN
    INSERT
    INTO
        account
    (id, kind
    )
    VALUES
        (new_id, chatter_kind
        );
    RETURN new_id;
END;
CREATE OR REPLACE FUNCTION chatter_insert
(
    table_name VARCHAR2
) RETURN NUMBER(19) AS
BEGIN
    RETURN chatter_insert(table_kind(table_name));
END;
CREATE OR REPLACE FUNCTION message_insert
(
    message_from_value NUMBER(19),
    message_value      VARCHAR2(500),
    viewed_value       VARCHAR2(1),
    chat_id_value      NUMBER(19)
) RETURN NUMBER AS
DECLARE
    message_id NUMBER(19);
BEGIN
    message_id := notifiable_insert('message');
    INSERT
    INTO
        message
    (id, message_from, message, viewed, time, chat_id
    )
    VALUES
        ( message_id
        , message_from_value
        , message_value
        , viewed_value
        , SYSDATE
        , chat_id_value
        );
    RETURN message_id;
END;
CREATE OR REPLACE FUNCTION group_insert
(
      group_title      VARCHAR2(75)
    , group_summary    VARCHAR2(255)
    , group_status     NUMBER(5)
    , group_content    VARCHAR2(500)
    , group_owner      NUMBER(19)
    , group_visibility VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN group_insert(
            group_title
        , group_summary
        , group_status
        , group_content
        , group_owner
        , table_kind(group_visibility)
        );
END;
CREATE OR REPLACE FUNCTION notifiable_insert
(
    notifiable_kind NUMBER(4)
) RETURN NUMBER(19) AS
DECLARE
    new_id NUMBER(19) := notifiable_seq.NEXTVAL;
BEGIN
    INSERT
    INTO
        notifiable
    (id, kind
    )
    VALUES
        (new_id, notifiable_kind
        );
    RETURN new_id;
END;
CREATE OR REPLACE FUNCTION notifiable_insert
(
    table_name VARCHAR2
) RETURN NUMBER(19) AS
BEGIN
    RETURN notifiable_insert(table_kind(table_name));
END;

-- ########## ENTITY INSERTS ##################################################
CREATE OR REPLACE FUNCTION entity_insert
(
      OWNER             NUMBER(19)
    , entity_visibility NUMBER(10)
    , entity_kind       NUMBER(4)
) RETURN NUMBER(19) AS
DECLARE
    NEW_ENTITY_ID NUMBER(19);
BEGIN
    NEW_ENTITY_ID := notifiable_insert(entity_kind);
    INSERT
    INTO
        entity
    (id, owner_id, time_created, visibility, active, kind
    )
    VALUES
        (NEW_ENTITY_ID, OWNER, SYSDATE, entity_visibility, 1, entity_kind
        );
    RETURN NEW_ENTITY_ID;
END;
CREATE OR REPLACE FUNCTION entity_insert
(
      OWNER             NUMBER(19)
    , entity_visibility VARCHAR2
    , entity_kind       VARCHAR2
) RETURN NUMBER(19) AS
BEGIN
    RETURN entity_insert(
            OWNER
        , visibility(entity_visibility)
        , table_kind(entity_kind)
        );
END;
CREATE OR REPLACE FUNCTION post_insert
(
      text_value      VARCHAR2(500)
    , target_feed     NUMBER(19)
    , post_kind       NUMBER(4)
    , OWNER_ID        NUMBER
    , post_visibility NUMBER(10)
) RETURN NUMBER AS
DECLARE
    post_id NUMBER := entity_insert
                          (OWNER_ID
                          , post_visibility
                          , table_kind('POST'));

BEGIN
    INSERT
    INTO
        post(id, feed_id, text, kind
            )
    VALUES
        (post_id, target_feed, text_value, post_kind
        );
    RETURN post_id;
END;
-- post isn't abstract
CREATE OR REPLACE FUNCTION post_insert
(
      text_value  VARCHAR2(500)
    , target_feed NUMBER(19)
    , post_kind   VARCHAR2
    , OWNER_ID    NUMBER
    , visibility  VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN post_insert(text_value, target_feed, table_kind(post_kind), OWNER_ID, visibility(visibility));
END;
CREATE OR REPLACE FUNCTION event_insert
(
    event_timing DATE, event_owner NUMBER(19), event_visibility NUMBER(10)
) RETURN NUMBER
    IS
    NEW_ID NUMBER;
BEGIN
    NEW_ID := entity_insert(event_owner, event_visibility, 'event');
    INSERT
    INTO
        event
    (id, timing
    )
    VALUES
        (NEW_ID, event_timing
        );
    RETURN NEW_ID;
END;
CREATE OR REPLACE FUNCTION event_insert
(
    event_timing DATE, event_owner NUMBER(19), event_visibility VARCHAR2
) RETURN NUMBER
    IS
BEGIN
    RETURN event_insert(
            event_timing
        , event_owner
        , visibility(event_visibility)
        );
END;
CREATE OR REPLACE FUNCTION notification_insert
(
    user_id_value NUMBER(19),
    type_value    VARCHAR2(50),
    item_id_value NUMBER(19)
) RETURN NUMBER AS
DECLARE
    notification_id NUMBER(19);
BEGIN
    notification_id := notifications_seq.NEXTVAL;
    INSERT
    INTO
        notification
    (id, user_id, "TYPE", item_id, time_created
    )
    VALUES
        (notification_id, user_id_value, type_value, item_id_value, SYSDATE
        );
    RETURN notification_id;
END;
CREATE OR REPLACE FUNCTION media_insert
(
      path_value            VARCHAR2(100)
    , text                  VARCHAR2(500)
    , target_feed           NUMBER(19)
    , post_owner            NUMBER
    , media_post_visibility NUMBER
) RETURN NUMBER AS
DECLARE
    media_id NUMBER(19);
BEGIN
    media_id := post_insert(text, target_feed, 'media', post_owner, media_post_visibility);
    INSERT
    INTO
        media
    (id, path
    )
    VALUES
        (media_id, path_value
        );
    RETURN media_id;
END;
CREATE OR REPLACE FUNCTION media_insert
(
      path_value            VARCHAR2(100)
    , text                  VARCHAR2(500)
    , target_feed           NUMBER(19)
    , post_owner            NUMBER
    , media_post_visibility VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN media_insert(
            path_value
        , text
        , target_feed
        , post_owner
        , visibility(media_post_visibility)
        );
END;
CREATE OR REPLACE FUNCTION share_insert
(
      post_id_value NUMBER(19)
    , text          VARCHAR2(500)
    , target_feed   NUMBER(19)
    , share_owner   NUMBER
    , visibility    NUMBER
) RETURN NUMBER AS
DECLARE
    share_id NUMBER(19);
BEGIN
    share_id := post_insert(
            text
        , target_feed
        , 'share'
        , share_owner
        , visibility
        );
    INSERT
    INTO
        "SHARE"
    (id, post_id
    )
    VALUES
        (share_id, post_id_value
        );
    RETURN share_id;
END;
CREATE OR REPLACE FUNCTION share_insert
(
      post_id_value    NUMBER(19)
    , text             VARCHAR2(500)
    , target_feed      NUMBER(19)
    , share_owner      NUMBER
    , share_visibility VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN share_insert(
            post_id_value
        , text
        , target_feed
        , share_owner
        , visibility(share_visibility)
        );
END;
CREATE OR REPLACE FUNCTION comment_insert
(
      post_id_value      NUMBER(19)
    , text               VARCHAR2(500)
    , target_feed        NUMBER(19)
    , comment_owner      NUMBER
    , comment_visibility NUMBER
) RETURN NUMBER AS
DECLARE
    comment_id NUMBER(19);
BEGIN
    comment_id := post_insert(
            text,
            target_feed,
            'comment', comment_owner, comment_visibility);
    INSERT
    INTO
        comment
    (id, post_id
    )
    VALUES
        (comment_id, post_id_value
        );
    RETURN comment_id;
END;
CREATE OR REPLACE FUNCTION comment_insert
(
      comment_post_id    NUMBER(19)
    , text               VARCHAR2(500)
    , target_feed        NUMBER(19)
    , comment_owner      NUMBER
    , comment_visibility VARCHAR2
) RETURN NUMBER AS
BEGIN
    RETURN comment_insert(
            comment_post_id
        , text
        , target_feed
        , comment_owner
        , visibility(comment_visibility)
        );
END;
CREATE OR REPLACE FUNCTION react_insert
(
      react_post_id NUMBER(19)
    , react_user_id NUMBER(19)
    , react_type    VARCHAR2(50)
) RETURN NUMBER AS
DECLARE
    react_id           NUMBER(19);
    reacted_to_user_id NUMBER(19);
BEGIN
    react_id := notifiable_insert('react');
    -- Get the user_id of the person who reacted to the post
    SELECT owner_id INTO reacted_to_user_id FROM entity WHERE id = react_post_id;
    notification_insert(reacted_to_user_id, 1, react_id);
    INSERT
    INTO
        react
    (id, post_id, user_id, "TYPE"
    )
    VALUES
        (react_id, react_post_id, react_user_id, react_type
        );
    RETURN react_id;
END;
CREATE OR REPLACE FUNCTION user_relationship_insert
(
      sourceId            NUMBER(19)
    , targetId            NUMBER(19)
    , relationship_type   NUMBER(5)
    , relationship_status NUMBER(5)
    , relationship_notes  VARCHAR2(500)
) RETURN NUMBER AS
DECLARE
    relationship_id NUMBER(19);
BEGIN
    relationship_id := notifiable_insert('account_relationship');
    INSERT
    INTO
        account_relationship
    (id, source_id, target_id, "TYPE", created, updated, status, notes
    )
    VALUES
        ( relationship_id, sourceId, targetId, relationship_type, SYSDATE, SYSDATE, relationship_status
        , relationship_notes
        );
    RETURN relationship_id;
END;
CREATE OR REPLACE FUNCTION conversation_insert
(
      user1Id NUMBER(19)
    , user2Id NUMBER(19)
) RETURN NUMBER AS
DECLARE
    conversation_id NUMBER(19);
BEGIN
    conversation_id := chat_insert('conversation');
    INSERT
    INTO
        conversation
    (id, user_1_id, user_2_id
    )
    VALUES
        (conversation_id, user1Id, user2Id
        );
    RETURN conversation_id;
END;
CREATE OR REPLACE FUNCTION group_chat_insert
(
    group_name VARCHAR2(50)
) RETURN NUMBER AS
DECLARE
    group_chat_id NUMBER(19);
BEGIN
    group_chat_id := chat_insert('group_chat_insert');
    INSERT
    INTO
        group_chat
    (id, name
    )
    VALUES
        (group_chat_id, group_name
        );
    RETURN group_chat_id;
END;
CREATE OR REPLACE FUNCTION member_insert
(
      chatterId       NUMBER(19)
    , group_chatId    NUMBER(19)
    , membership_type NUMBER(3)
) RETURN NUMBER AS
DECLARE
    member_id NUMBER(19);
BEGIN
    member_id := member_seq.nextval;
    INSERT
    INTO
        member
    (id, "TYPE", chatter_id, group_chat_id
    )
    VALUES
        (member_id, membership_type, chatterId, group_chatId
        );
    RETURN member_id;
END;
CREATE OR REPLACE FUNCTION participant_insert
(
      eventId NUMBER(19)
    , userId  NUMBER(19)
) RETURN NUMBER AS
DECLARE
    participant_id NUMBER(19);
BEGIN
    participant_id := participant_seq.nextval;
    INSERT
    INTO
        event_participant
    (id, event_id, user_id
    )
    VALUES
        (participant_id, eventId, userId
        );
    RETURN participant_id;
END;
CREATE OR REPLACE FUNCTION visibility_user_list_insert
(
      entityId NUMBER(19)
    , userId   NUMBER(19)
) RETURN NUMBER AS
DECLARE
    visibility_user_list_id NUMBER(19);
BEGIN
    visibility_user_list_id := visibility_user_list_seq.nextval;
    INSERT
    INTO
        visibility_user_set
    (id, entity_id, user_id
    )
    VALUES
        (visibility_user_list_id, entityId, userId
        );
    RETURN visibility_user_list_id;
END;