-- notifiable = false abstract
-- account = false abstract
-- chat = false abstract
-- notification = true
-- member = true
-- event_participant = true
-- visibility_user_set = true
-- group_member = true
-- ########### 8 sequences needed ###########
-- entity -> notifiable = false soft by entity
-- feed -> entity -> notifiable = false soft by entity
-- group -> entity -> notifiable = false soft by entity
-- event -> entity -> notifiable = false soft by entity
-- post -> entity -> notifiable = false soft by entity
-- media -> post -> entity -> notifiable = false soft by entity
-- comment -> post -> entity -> notifiable = false soft by entity
-- share -> post -> entity -> notifiable = false soft by entity
-- message -> notifiable ???
-- react -> notifiable ???
-- relationship -> notifiable ???
-- user_page_relationship -> notifiable ???
-- user -> account ???
-- page -> account ???
-- conversation -> chat ???
-- group_chat -> chat ???
CREATE OR REPLACE PROCEDURE delete_visibility_user_set
(
    entityId NUMBER(19)
    , userId NUMBER(19)
) IS
begin
    delete from visibility_user_set where entity_id = entityId and user_id = userId;
END;
CREATE OR REPLACE PROCEDURE delete_event_participant
(
    eventId NUMBER(19)
    , userId NUMBER(19)
) IS
begin
    delete from event_participant where event_id = eventId and user_id = userId;
END;
CREATE OR REPLACE PROCEDURE delete_entity
(
    entityId NUMBER(19)
) IS
begin
    UPDATE entity SET active = 0 WHERE id = entityId;
END;
    --group member
    --member
    --notification