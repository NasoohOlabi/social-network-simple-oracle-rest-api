-- feed -> entity -> notifiable
CREATE TABLE feed
(
    id NUMBER(19) NOT NULL,
    CONSTRAINT fk_feed_entity
        FOREIGN KEY (id)
            REFERENCES entity (id),
    PRIMARY KEY (id)
)
;

-- user -> account
CREATE TABLE "USER"
(
    id           NUMBER(19)              NOT NULL,
    first_name   VARCHAR2(50)            NOT NULL,
    middle_name  VARCHAR2(50)            NOT NULL,
    last_name    VARCHAR2(50)            NOT NULL,
    username     VARCHAR2(50)            NOT NULL,
    mobile       NUMBER(15)              NOT NULL,
    email        VARCHAR2(50)            NOT NULL,
    passwordHash VARCHAR2(32)            NOT NULL,
    registeredAt DATE                    NOT NULL,
    lastLogin    DATE                    NOT NULL,
    intro        VARCHAR2(255) DEFAULT NULL,
    profile      VARCHAR2(500) DEFAULT NULL,
    feed_id      NUMBER(19)              NOT NULL,
    chat_id      NUMBER(19)              NOT NULL,
    active       NUMBER(1)     DEFAULT 1 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_user_feed
        FOREIGN KEY (feed_id)
            REFERENCES feed (id),
    CONSTRAINT fk_user_account
        FOREIGN KEY (id)
            REFERENCES account (id)
)
;
-- trigger to forbid changes to feed_id and chat_id and registeredAt
CREATE OR REPLACE TRIGGER "USER_BEFORE_INSERT"
    BEFORE UPDATE
    ON "USER"
    FOR EACH ROW
BEGIN
    :NEW.feed_id := :OLD.feed_id;
    :NEW.chat_id := :OLD.chat_id;
    :NEW.registeredAt := :OLD.registeredAt;
END;


CREATE UNIQUE INDEX uq_mobile ON "USER" (mobile ASC);
CREATE UNIQUE INDEX uq_username ON "USER" (username ASC);
CREATE UNIQUE INDEX uq_email ON "USER" (email ASC);

CREATE UNIQUE INDEX fk_uq_user_chat_id on "USER" (chat_id ASC);
CREATE UNIQUE INDEX fk_uq_user_feed_id on "USER" (feed_id ASC);

-- chat
CREATE TABLE chat
(
    id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    kind NUMBER(4)  NOT NULL
)
;

-- page -> account
CREATE TABLE page
(
    id      NUMBER(19) NOT NULL,
    name    VARCHAR2(30) NOT NULL ,
    feed_id NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_page_account
        FOREIGN KEY (id)
            REFERENCES account (id),
    CONSTRAINT fk_page_feed
        FOREIGN KEY (feed_id)
            REFERENCES feed (id)
)
;


CREATE UNIQUE INDEX uq_page_feed_id ON page (feed_id ASC);
CREATE UNIQUE INDEX uq_page_name ON page (name ASC);

-- account
CREATE TABLE account
(
    id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    kind NUMBER(4)  NOT NULL
)
;

-- message -> notifiable
CREATE TABLE message
(
    id           NUMBER(19)    NOT NULL,
    CONSTRAINT fk_notifiable
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    message_from NUMBER(19)    NOT NULL,
    message      VARCHAR2(500) NOT NULL,
    viewed       VARCHAR2(1)   NOT NULL,
    time         DATE          NOT NULL,
    chat_id      NUMBER(19)    NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_chat
        FOREIGN KEY (chat_id)
            REFERENCES chat (id),
    CONSTRAINT fk_message
        FOREIGN KEY (message_from)
            REFERENCES account (id)
)
;

CREATE INDEX fk_message_message_from ON message (message_from ASC);
CREATE INDEX fk_message_chat_id ON message (chat_id ASC);

-- group_chat -> chat
CREATE TABLE group_chat
(
    id   NUMBER(19)   NOT NULL,
    name VARCHAR2(50) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_group_chat_chat
        FOREIGN KEY (id)
            REFERENCES chat (id)
)
;

-- post -> entity -> notifiable
CREATE TABLE post
(
    id      NUMBER(19)                 NOT NULL,
    CONSTRAINT fk_post_entity
        FOREIGN KEY (id)
            REFERENCES entity (id),
    feed_id NUMBER(19)                 NOT NULL,
    text    VARCHAR2(500) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_post_feed
        FOREIGN KEY (feed_id)
            REFERENCES feed (id),
    kind    NUMBER(4)                  NOT NULL
)
;

CREATE INDEX fk_post_feed_id ON post (feed_id ASC);

-- entity -> notifiable
CREATE TABLE entity
(
    id           NUMBER(19)           NOT NULL,
    CONSTRAINT fk_entity_notifiable
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    owner_id     NUMBER(19)           NOT NULL,
    time_created DATE                 NOT NULL,
    visibility   NUMBER(10)           NOT NULL,
    active       NUMBER(10) DEFAULT 1 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_entity_account
        FOREIGN KEY (id)
            REFERENCES account (id),
    kind         NUMBER(4)            NOT NULL
)
;
CREATE INDEX fk_entity_owner_id ON entity (owner_id ASC);
-- visibility enum table:
-- 1 - public
-- 2 - only me
-- 3 - friends
-- 4 - visible to user list
-- 5 - not visible to user list

CREATE TABLE notifiable
(
    id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    kind NUMBER(4)  NOT NULL
);

/

-- notification
CREATE TABLE notification
(
    id           NUMBER(19)            NOT NULL,
    type         VARCHAR2(50)          NOT NULL,
    account_id      NUMBER(19)            NOT NULL,
    viewed       Number(1) DEFAULT 0 NULL,
    time_created DATE                  NOT NULL,
    item_id      NUMBER(19)            NULL,
    PRIMARY KEY (account_id,id),
    CONSTRAINT fk_notification_account
        FOREIGN KEY (account_id)
            REFERENCES account (id),
    CONSTRAINT fk_notification_notifiable
        FOREIGN KEY (item_id)
            REFERENCES notifiable (id)
)
;

CREATE INDEX fk_notification_item_id ON notification (item_id ASC);

-- member
CREATE TABLE member
(
    id            NUMBER(19)             NOT NULL,
    PRIMARY KEY (id),
    account_id    NUMBER(19)             NOT NULL,
    type          NUMBER(3) DEFAULT NULL NULL,
    group_chat_id NUMBER(19)             NOT NULL,
    CONSTRAINT fk_member_account
        FOREIGN KEY (account_id)
            REFERENCES account (id),
    CONSTRAINT fk_member_group_chat
        FOREIGN KEY (group_chat_id)
            REFERENCES group_chat (id)
)
;


CREATE UNIQUE INDEX user_id_UNIQUE ON member (account_id ASC, group_chat_id ASC);

CREATE INDEX fk_member_group_chat_id ON member (group_chat_id ASC);
CREATE INDEX fk_member_account_id ON member (account_id ASC);

-- media -> post -> entity -> notifiable
CREATE TABLE media
(
    id   NUMBER(19)    NOT NULL,
    path VARCHAR2(100) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_media_post
        FOREIGN KEY (id)
            REFERENCES post (id)
)
;

-- share -> post -> entity -> notifiable
CREATE TABLE "SHARE"
(
    id      NUMBER(19) NOT NULL,
    post_id NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_share_post
        FOREIGN KEY (id)
            REFERENCES post (id),
    CONSTRAINT fk_share_shared_post
        FOREIGN KEY (post_id)
            REFERENCES post (id)
)
;

CREATE INDEX fk_share_post_id ON "SHARE" (post_id ASC);

-- react -> notifiable
CREATE TABLE react
(
    id      NUMBER(19)                NOT NULL,
    CONSTRAINT fk_notifiable_id
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    user_id NUMBER(19)                NOT NULL,
    post_id NUMBER(19)                NOT NULL,
    type    VARCHAR2(50) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_react_user
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id),
    CONSTRAINT fk_react_post
        FOREIGN KEY (post_id)
            REFERENCES post (id)
)
;

CREATE INDEX fk_react_user_id ON react (user_id ASC);
CREATE INDEX fk_react_post_id ON react (post_id ASC);

-- comment -> post -> entity -> notifiable
CREATE TABLE "COMMENT"
(
    id      NUMBER(19)                 NOT NULL,
    post_id NUMBER(19)                 NOT NULL,
    text    VARCHAR2(500) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_comment_post
        FOREIGN KEY (post_id)
            REFERENCES post (id),
    CONSTRAINT fk_comment_entity
        FOREIGN KEY (id)
            REFERENCES post (id)
)
;


CREATE INDEX fk_comment_post_id ON "COMMENT" (post_id ASC);

-- account_relationship -> notifiable
CREATE TABLE account_relationship
(
    id        NUMBER(19)                 NOT NULL,
    CONSTRAINT fk_notifiable_id
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    source_id NUMBER(19)                 NOT NULL,
    target_id NUMBER(19)                 NOT NULL,
    type      NUMBER(5)     DEFAULT '0'  NOT NULL,
    status    NUMBER(5)     DEFAULT '0'  NOT NULL,
    created   DATE                       NOT NULL,
    updated   DATE          DEFAULT NULL NULL,
    notes     VARCHAR2(500) DEFAULT NULL NULL,
    chat_id   NUMBER(19)                 NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_friend_source
        FOREIGN KEY (source_id)
            REFERENCES account (id),
    CONSTRAINT fk_friend_target
        FOREIGN KEY (target_id)
            REFERENCES account (id),
    CONSTRAINT fk_relationship_chat
        FOREIGN KEY (chat_id)
            REFERENCES chat (id)
)
;

CREATE UNIQUE INDEX uq_friend ON account_relationship (source_id ASC, target_id ASC);
CREATE INDEX fk_account_relationship_source_id ON account_relationship (source_id ASC);
CREATE INDEX fk_account_relationship_target_id ON account_relationship (target_id ASC);
CREATE INDEX fk_account_relationship_chat_id ON account_relationship (chat_id ASC);

-- visibility_user_set
CREATE TABLE visibility_user_set
(
    id        NUMBER(19) NOT NULL,
    entity_id NUMBER(19) NOT NULL,
    user_id   NUMBER(19) NOT NULL,
    PRIMARY KEY (entity_id,id),
    CONSTRAINT fk_visibility_user_set_entity
        FOREIGN KEY (entity_id)
            REFERENCES entity (id),
    CONSTRAINT fk_visibility_user_set_user
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;

CREATE INDEX fk_visibility_user_set_user_id ON visibility_user_set (user_id ASC);

-- event -> entity -> notifiable
CREATE TABLE event
(
    id     NUMBER(19) NOT NULL,
    timing DATE       NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_event_id
        FOREIGN KEY (id)
            REFERENCES entity (id)
)
;

-- event_participant
CREATE TABLE event_participant
(
    id       NUMBER(19) NOT NULL,
    event_id NUMBER(19) NOT NULL,
    user_id  NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_event_participant_event
        FOREIGN KEY (event_id)
            REFERENCES event (id),
    CONSTRAINT fk_event_participant_user
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;


CREATE INDEX fk_event_participant_user_id ON event_participant (user_id ASC);
CREATE INDEX fk_event_participant_event_id ON event_participant (event_id ASC);

CREATE OR REPLACE VIEW active_users AS
SELECT
    id
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
FROM
    "USER"
WHERE
    active = 1;

CREATE OR REPLACE VIEW active_entities AS
SELECT
    id
  , owner_id
  , time_created
  , visibility
  , kind
FROM
    entity
WHERE
    active = 1;