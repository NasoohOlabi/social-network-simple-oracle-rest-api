-- chat
-- account
-- comment
-- conversation
-- entity
-- event
-- feed
-- group_chat
-- media
-- member
-- message
-- notifiable
-- notification
-- page
-- event_participant
-- post
-- react
-- share
-- user
-- account_relationship
-- visibility_user_set
CREATE OR REPLACE FUNCTION table_kind
(
    table_name VARCHAR2
) RETURN NUMBER AS
BEGIN
    CASE LOWER(table_name)
        WHEN 'chat' THEN RETURN 1;
        WHEN 'account' THEN RETURN 2;
        WHEN 'comment' THEN RETURN 3;
        WHEN 'conversation' THEN RETURN 4;
        WHEN 'entity' THEN RETURN 5;
        WHEN 'event' THEN RETURN 6;
        WHEN 'feed' THEN RETURN 7;
        WHEN 'group_chat' THEN RETURN 8;
        WHEN 'media' THEN RETURN 9;
        WHEN 'member' THEN RETURN 10;
        WHEN 'message' THEN RETURN 11;
        WHEN 'notifiable' THEN RETURN 12;
        WHEN 'notification' THEN RETURN 13;
        WHEN 'page' THEN RETURN 14;
        WHEN 'event_participant' THEN RETURN 15;
        WHEN 'post' THEN RETURN 16;
        WHEN 'react' THEN RETURN 17;
        WHEN 'share' THEN RETURN 18;
        WHEN 'user' THEN RETURN 19;
        WHEN 'account_relationship' THEN RETURN 20;
        WHEN 'visibility_user_set' THEN RETURN 21;
        WHEN 'saved_massages' THEN RETURN 22;
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
        WHEN 2 THEN RETURN 'account';
        WHEN 3 THEN RETURN 'comment';
        WHEN 4 THEN RETURN 'conversation';
        WHEN 5 THEN RETURN 'entity';
        WHEN 6 THEN RETURN 'event';
        WHEN 7 THEN RETURN 'feed';
        WHEN 8 THEN RETURN 'group_chat';
        WHEN 9 THEN RETURN 'media';
        WHEN 10 THEN RETURN 'member';
        WHEN 11 THEN RETURN 'message';
        WHEN 12 THEN RETURN 'notifiable';
        WHEN 13 THEN RETURN 'notification';
        WHEN 14 THEN RETURN 'page';
        WHEN 15 THEN RETURN 'event_participant';
        WHEN 16 THEN RETURN 'post';
        WHEN 17 THEN RETURN 'react';
        WHEN 18 THEN RETURN 'share';
        WHEN 19 THEN RETURN 'user';
        WHEN 20 THEN RETURN 'account_relationship';
        WHEN 21 THEN RETURN 'visibility_user_set';
        WHEN 22 THEN RETURN 'saved_massages';
        ELSE RETURN 'unknown';
        END CASE;
END;