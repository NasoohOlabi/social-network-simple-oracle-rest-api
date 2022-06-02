-- chat
-- chatter
-- comment
-- conversation
-- entity
-- event
-- feed
-- group
-- group_chat
-- group_member
-- media
-- member
-- message
-- notifiable
-- notification
-- page
-- participant
-- post
-- react
-- share
-- user
-- user_relationship
-- user_page_relationship
-- visibility_user_set
CREATE OR REPLACE FUNCTION table_kind
(
    table_name VARCHAR2
) RETURN NUMBER AS
BEGIN
    CASE LOWER(table_name)
        WHEN 'chat' THEN RETURN 1;
        WHEN 'chatter' THEN RETURN 2;
        WHEN 'comment' THEN RETURN 3;
        WHEN 'conversation' THEN RETURN 4;
        WHEN 'entity' THEN RETURN 5;
        WHEN 'event' THEN RETURN 6;
        WHEN 'feed' THEN RETURN 7;
        WHEN 'group' THEN RETURN 8;
        WHEN 'group_chat' THEN RETURN 9;
        WHEN 'group_member' THEN RETURN 10;
        WHEN 'media' THEN RETURN 11;
        WHEN 'member' THEN RETURN 12;
        WHEN 'message' THEN RETURN 13;
        WHEN 'notifiable' THEN RETURN 14;
        WHEN 'notification' THEN RETURN 15;
        WHEN 'page' THEN RETURN 16;
        WHEN 'participant' THEN RETURN 17;
        WHEN 'post' THEN RETURN 18;
        WHEN 'react' THEN RETURN 19;
        WHEN 'share' THEN RETURN 20;
        WHEN 'user' THEN RETURN 21;
        WHEN 'user_relationship' THEN RETURN 22;
        WHEN 'user_page_relationship' THEN RETURN 23;
        WHEN 'visibility_user_set' THEN RETURN 24;
        WHEN 'saved_massages' THEN RETURN 25;
        ELSE RETURN 0;
        END CASE;
END;

CREATE OR REPLACE FUNCTION table_kind
(
    table_id NUMBER
)
    RETURN VARCHAR2
    IS
BEGIN
    CASE table_id
        WHEN 1 THEN RETURN 'chat';
        WHEN 2 THEN RETURN 'chatter';
        WHEN 3 THEN RETURN 'comment';
        WHEN 4 THEN RETURN 'conversation';
        WHEN 5 THEN RETURN 'entity';
        WHEN 6 THEN RETURN 'event';
        WHEN 7 THEN RETURN 'feed';
        WHEN 8 THEN RETURN 'group';
        WHEN 9 THEN RETURN 'group_chat';
        WHEN 10 THEN RETURN 'group_member';
        WHEN 11 THEN RETURN 'media';
        WHEN 12 THEN RETURN 'member';
        WHEN 13 THEN RETURN 'message';
        WHEN 14 THEN RETURN 'notifiable';
        WHEN 15 THEN RETURN 'notification';
        WHEN 16 THEN RETURN 'page';
        WHEN 17 THEN RETURN 'participant';
        WHEN 18 THEN RETURN 'post';
        WHEN 19 THEN RETURN 'react';
        WHEN 20 THEN RETURN 'share';
        WHEN 21 THEN RETURN 'user';
        WHEN 22 THEN RETURN 'user_relationship';
        WHEN 23 THEN RETURN 'user_page_relationship';
        WHEN 24 THEN RETURN 'visibility_user_set';
        WHEN 25 THEN RETURN 'saved_massages';
        ELSE RETURN 'unknown';
        END CASE;
END;