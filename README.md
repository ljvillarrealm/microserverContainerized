# microserverContanerized

This is the containerized version of [santimatiz/microserver](https://github.com/santimatiz/microserver) that I made this project based on the [API-REST con Postgresql y MicroServer course](https://www.udemy.com/course/api-rest-con-postgresql/).

This project is built using podman and this is how it works:
![diagram](./images/diagram.png)
![config](./images/podman_run.png)

This project is organized this way:

- The folder 'microserver' is a copy of the original repo.
- The folder 'project_resources' contains all the scripts related to projects developed in the course.
- The folder 'microserver_containerized' is the folder where is possible to exec $podman compose up.

Notes:

- Optionally is possible to use the [wait-for-it](https://github.com/vishnubob/wait-for-it) script.

## Projects

### Project 1 evidences

![Project 1 - test in postman](./images/test_postman.png)

### Project 2 evidences

![Project 2 - test in postman](./images/test_postman_2.png)
![Project 2 json variant - test in postman](./images/test_postman_2_json.png)

### Project 3 evidences

![Project 3 - test in postman](./images/test_postman_3.png)
![Project 3 token table - test in postman](./images/test_postman_3_tokenTable.png)
![Project 3 token table - test in postman](./images/test_postman_3_salutadejsontok.png)

### Project 6 evidences

![Project 6 - service /createuser/v1](./images/servicecreateuserv1.png)
![Project 6 - use service /createuser/v1](./images/useservicecreateuserv1.png)
![Project 6 - already exists](./images/alreadyexists.png)
![Project 6 - password not valid](./images/passwordnotvalid.png)
![Project 6 - email not valid](./images/emailnotvalid.png)
![Project 6 - uncleaned and cleaned user creation](./images/uncleanedandcleanedusercreation.png)
![Project 6 - user logged in ok](./images/userloggedinok.png)
![Project 6 - user not logged](./images/usernotlogged.png)
