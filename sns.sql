-- feed -> entity -> notifiable
CREATE TABLE feed
(
    id NUMBER(19) NOT NULL,
    CONSTRAINT fk_entity_id
        FOREIGN KEY (id)
            REFERENCES entity (id),
    PRIMARY KEY (id)
)
;

-- user -> chatter
CREATE TABLE "USER"
(
    id           NUMBER(19)                 NOT NULL,
    first_name   VARCHAR2(50)               NOT NULL,
    middle_name  VARCHAR2(50)               NOT NULL,
    last_name    VARCHAR2(50)               NOT NULL,
    username     VARCHAR2(50)               NOT NULL,
    mobile       NUMBER(15)                 NOT NULL,
    email        VARCHAR2(50)               NOT NULL,
    passwordHash VARCHAR2(32)               NOT NULL,
    registeredAt DATE                       NOT NULL,
    lastLogin    DATE                       NOT NULL,
    intro        VARCHAR2(255) DEFAULT NULL NULL,
    profile      VARCHAR2(500) DEFAULT NULL NULL,
    feed_id      NUMBER(19)                 NOT NULL,
    chat_id      NUMBER(19)                 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_user_feed1
        FOREIGN KEY (feed_id)
            REFERENCES feed (id),
    CONSTRAINT fk_chatter_user
        FOREIGN KEY (id)
            REFERENCES chatter (id)
)
;

CREATE INDEX fk_user_chat_idx ON "USER" (chat_id ASC);


CREATE UNIQUE INDEX uq_username ON "USER" (username ASC);


CREATE UNIQUE INDEX uq_mobile ON "USER" (mobile ASC);


CREATE UNIQUE INDEX uq_email ON "USER" (email ASC);


CREATE INDEX fk_user_feed1_idx ON "USER" (feed_id ASC);


CREATE UNIQUE INDEX feed_id_UNIQUE ON "USER" (feed_id ASC);

-- chat
CREATE TABLE chat
(
    id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    kind NUMBER(4)  NOT NULL
)
;

-- page -> chatter
CREATE TABLE page
(
    id      NUMBER(19) NOT NULL,
    feed_id NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_chatter_page
        FOREIGN KEY (id)
            REFERENCES chatter (id),
    CONSTRAINT fk_page_feed1
        FOREIGN KEY (feed_id)
            REFERENCES feed (id)
)
;


CREATE INDEX fk_page_feed1_idx ON page (feed_id ASC);

-- chatter
CREATE TABLE chatter
(
    id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    kind NUMBER(4)  NOT NULL
)
;


CREATE INDEX fk_chatter_idx ON chatter (id ASC);

-- message -> notifiable
CREATE TABLE message
(
    id           NUMBER(19)               NOT NULL,
    CONSTRAINT fk_notifiable_id
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    message_from NUMBER(19)               NOT NULL,
    message      VARCHAR2(500)            NOT NULL,
    viewed       VARCHAR2(1) DEFAULT NULL NULL,
    time         DATE                     NOT NULL,
    chat_id      NUMBER(19)               NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_chat_id
        FOREIGN KEY (chat_id)
            REFERENCES chat (id),
    CONSTRAINT fk_message_from
        FOREIGN KEY (message_from)
            REFERENCES chatter (id)
)
;

/


CREATE INDEX message_from ON message (message_from ASC);


CREATE INDEX fk_message_chat1_idx ON message (chat_id ASC);

-- group -> entity -> notifiable
CREATE TABLE "GROUP"
(
    id      NUMBER(19)                 NOT NULL,
    CONSTRAINT fk_entity_id
        FOREIGN KEY (id)
            REFERENCES entity (id),
    title   VARCHAR2(75)               NOT NULL,
    summary VARCHAR2(255) DEFAULT NULL NULL,
    status  NUMBER(5)     DEFAULT '0'  NOT NULL,
    content VARCHAR2(500) DEFAULT NULL NULL,
    feed_id NUMBER(19)                 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_group_feed1
        FOREIGN KEY (feed_id)
            REFERENCES feed (id)
)
;



CREATE INDEX fk_group_feed1_idx ON "GROUP" (feed_id ASC);

-- group_chat -> chat
CREATE TABLE group_chat
(
    id   NUMBER(19)   NOT NULL,
    name VARCHAR2(50) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_group_chat_chat1
        FOREIGN KEY (id)
            REFERENCES chat (id)
)
;


CREATE INDEX fk_group_chat_chat1_idx ON group_chat (id ASC);

-- post -> entity -> notifiable
CREATE TABLE post
(
    id      NUMBER(19)                 NOT NULL,
    CONSTRAINT fk_entity_id
        FOREIGN KEY (id)
            REFERENCES entity (id),
    feed_id NUMBER(19)                 NOT NULL,
    text    VARCHAR2(500) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_post_feed1
        FOREIGN KEY (feed_id)
            REFERENCES feed (id),
    kind    NUMBER(4)                  NOT NULL
)
;


CREATE INDEX fk_post_entity1_idx ON post (id ASC);


CREATE INDEX fk_post_feed1_idx ON post (feed_id ASC);

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
    CONSTRAINT fk_owner_id
        FOREIGN KEY (id)
            REFERENCES chatter (id),
    kind         NUMBER(4)            NOT NULL
)
;
-- visibility enum table:
-- 1 - public
-- 2 - only me
-- 3 - friends
-- 4 - visible to user list
-- 5 - not visible to user list

CREATE INDEX fk_notifiable_idx ON entity (id ASC);

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
    user_id      NUMBER(19)            NOT NULL,
    viewed       BOOLEAN DEFAULT FALSE NULL,
    time_created DATE                  NOT NULL,
    item_id      NUMBER(19)            NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_user_id
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id),
    CONSTRAINT fk_notifiable_id
        FOREIGN KEY (item_id)
            REFERENCES notifiable (id)
)
;


CREATE OR REPLACE TRIGGER notifications_seq_tr
    BEFORE INSERT
    ON notification
    FOR EACH ROW
    WHEN (NEW.id IS NULL)
BEGIN
    SELECT notifications_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/


CREATE INDEX fk_notifications_user1_idx ON notification (user_id ASC);

-- member
CREATE TABLE member
(
    id            NUMBER(19)             NOT NULL,
    PRIMARY KEY (id),
    chatter_id    NUMBER(19)             NOT NULL,
    type          NUMBER(3) DEFAULT NULL NULL,
    group_chat_id NUMBER(19)             NOT NULL,
    CONSTRAINT fk_user_id
        FOREIGN KEY (chatter_id)
            REFERENCES chatter (id),
    CONSTRAINT fk_group_chat_id
        FOREIGN KEY (group_chat_id)
            REFERENCES group_chat (id)
)
;


CREATE UNIQUE INDEX user_id_UNIQUE ON member (chatter_id ASC, group_chat_id ASC);

CREATE INDEX fk_participant_group_chat1_idx ON member (group_chat_id ASC);

-- conversation -> chat
CREATE TABLE conversation
(
    id        NUMBER(19) NOT NULL,
    user_1_id NUMBER(19) NOT NULL,
    user_2_id NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_user_1_chatter
        FOREIGN KEY (user_1_id)
            REFERENCES chatter (id),
    CONSTRAINT fk_user_2_chatter
        FOREIGN KEY (user_2_id)
            REFERENCES chatter (id),
    CONSTRAINT fk_chat_id
        FOREIGN KEY (id)
            REFERENCES chat (id)
)
;


CREATE UNIQUE INDEX user_2_id_UNIQUE ON conversation (user_2_id ASC, user_1_id ASC);


CREATE INDEX fk_conversation_user1_idx ON conversation (user_1_id ASC);

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
    CONSTRAINT fk_media_post
        FOREIGN KEY (id)
            REFERENCES post (id),
    CONSTRAINT fk_media_shared_post
        FOREIGN KEY (post_id)
            REFERENCES post (id)
)
;


CREATE INDEX fk_media_shared_post_idx ON "SHARE" (post_id ASC);

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
    CONSTRAINT fk_react_user1
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id),
    CONSTRAINT fk_react_post1
        FOREIGN KEY (post_id)
            REFERENCES post (id)
)
;


CREATE INDEX fk_react_user1_idx ON react (user_id ASC);


CREATE INDEX fk_react_post1_idx ON react (post_id ASC);

-- comment -> post -> entity -> notifiable
CREATE TABLE "COMMENT"
(
    id      NUMBER(19)                 NOT NULL,
    post_id NUMBER(19)                 NOT NULL,
    text    VARCHAR2(500) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_comment_post1
        FOREIGN KEY (post_id)
            REFERENCES post (id),
    CONSTRAINT fk_comment_entity
        FOREIGN KEY (id)
            REFERENCES post (id)
)
;


CREATE INDEX fk_comment_post1_idx ON "COMMENT" (post_id ASC);

-- user_page_relationship -> notifiable
CREATE TABLE user_page_relationship
(
    id      NUMBER(19) NOT NULL,
    CONSTRAINT fk_notifiable_id
        FOREIGN KEY (id)
            REFERENCES notifiable (id),
    page_id NUMBER(19) NOT NULL,
    user_id NUMBER(19) NOT NULL,
    type    NUMBER(10) NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_page_follower_page1
        FOREIGN KEY (page_id)
            REFERENCES page (id),
    CONSTRAINT fk_page_follower_user1
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;


CREATE INDEX fk_page_follower_page1_idx ON user_page_relationship (page_id ASC);


CREATE INDEX fk_page_follower_user1_idx ON user_page_relationship (user_id ASC);

-- group_member
CREATE TABLE group_member
(
    id       NUMBER(19)                 NOT NULL,
    group_id NUMBER(19)                 NOT NULL,
    user_id  NUMBER(19)                 NOT NULL,
    role_id  NUMBER(5)     DEFAULT '0'  NOT NULL,
    status   NUMBER(5)     DEFAULT '0'  NOT NULL,
    created  DATE                       NOT NULL,
    updated  DATE          DEFAULT NULL NULL,
    notes    VARCHAR2(500) DEFAULT NULL NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_member_group
        FOREIGN KEY (group_id)
            REFERENCES "GROUP" (id),
    CONSTRAINT fk_member_user
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;


CREATE UNIQUE INDEX uq_member ON group_member (group_id ASC, user_id ASC);


CREATE INDEX idx_member_group ON group_member (group_id ASC);


CREATE INDEX idx_member_user ON group_member (user_id ASC);

-- user_relationship -> notifiable
CREATE TABLE user_relationship
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
    PRIMARY KEY (id),
    CONSTRAINT fk_friend_source
        FOREIGN KEY (source_id)
            REFERENCES "USER" (id),
    CONSTRAINT fk_friend_target
        FOREIGN KEY (target_id)
            REFERENCES "USER" (id)
)
;



CREATE UNIQUE INDEX uq_friend ON user_relationship (source_id ASC, target_id ASC);


CREATE INDEX idx_friend_source ON user_relationship (source_id ASC);


CREATE INDEX idx_friend_target ON user_relationship (target_id ASC);

-- visibility_user_set
CREATE TABLE visibility_user_set
(
    id        NUMBER(19) NOT NULL,
    entity_id NUMBER(19) NOT NULL,
    user_id   NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_entity_has_user_entity1
        FOREIGN KEY (entity_id)
            REFERENCES entity (id),
    CONSTRAINT fk_entity_has_user_user1
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;


CREATE INDEX fk_entity_has_user_user1_idx ON visibility_user_set (user_id ASC);


CREATE INDEX fk_entity_has_user_entity1_idx ON visibility_user_set (entity_id ASC);

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

-- participant
CREATE TABLE participant
(
    id       NUMBER(19) NOT NULL,
    event_id NUMBER(19) NOT NULL,
    user_id  NUMBER(19) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_event_has_user_event1
        FOREIGN KEY (event_id)
            REFERENCES event (id),
    CONSTRAINT fk_event_has_user_user1
        FOREIGN KEY (user_id)
            REFERENCES "USER" (id)
)
;


CREATE INDEX fk_event_has_user_user1_idx ON participant (user_id ASC);


CREATE INDEX fk_event_has_user_event1_idx ON participant (event_id ASC);

