-- notifiable
-- chatter
-- chat
-- notification
-- member
-- participant
-- visibility_user_set
-- group_member
-- ########### 8 sequences needed ###########
-- entity -> notifiable
-- feed -> entity -> notifiable
-- group -> entity -> notifiable
-- message -> notifiable
-- event -> entity -> notifiable
-- post -> entity -> notifiable
-- media -> post -> entity -> notifiable
-- comment -> post -> entity -> notifiable
-- share -> post -> entity -> notifiable
-- user -> chatter
-- page -> chatter
-- react -> notifiable
-- user_relationship -> notifiable
-- user_page_relationship -> notifiable
-- conversation -> chat
-- group_chat -> chat
--
--
--
--
-- ########### 8 sequences needed ###########
CREATE SEQUENCE visibility_user_list_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE participant_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE group_member_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE member_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE notifications_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE notifiable_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE chatter_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE chat_seq START WITH 1 INCREMENT BY 1;
