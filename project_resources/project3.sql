-- --------------------------------  PROJECT 3  --------------------------------------------

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (5,'Saludate JSON','/saludatejsontok','SELECT microrest.saludatejson(''first_name'', ''last_name'')','GET','1');

INSERT INTO microrest.users
    (users, "password")
    VALUES('hans', '2121');

INSERT INTO microrest.restapi
    (id_restapi, "name", "path", query, "action", required_token)
    VALUES (6,'Get Token','/getToken','SELECT microrest.create_token(authorization)','POST','0');