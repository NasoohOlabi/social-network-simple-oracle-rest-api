-- notifiable = false abstract
-- chatter = false abstract
-- chat = false abstract
-- notification = true
-- member = true
-- participant = true
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
-- user_relationship -> notifiable ???
-- user_page_relationship -> notifiable ???
-- user -> chatter ???
-- page -> chatter ???
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
CREATE OR REPLACE PROCEDURE delete_particpant
(
    eventId NUMBER(19)
    , userId NUMBER(19)
) IS
begin
    delete from participant where event_id = eventId and user_id = userId;
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