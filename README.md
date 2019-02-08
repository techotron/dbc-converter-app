# WIP

# dbc-converter-app

## Overview
An over engineered application to convert .dbc files to .xlsx. I wanted to play around with the various AWS components used to learn about them. The idea is that someone can send a dbc file as an attachment which is then processed, converted and returned. 
<br>
The actual conversion uses canmatrix (https://github.com/ebroecker/canmatrix) by Eduard Broecker

##### High Level
E-mail sent to SES -> Rule saves the e-mail to S3 bucket -> S3 notification policy sends meta data to SQS -> SQS message used as event trigger for lambda function -> 

TODO: 
1. lambda function to populate dynamodb table with s3 details of the e-mail and then trigger state machine
2. State machine to read dynamoDb table to gather list of e-mails to process
3. Function within state machine extracts headers from e-mail (return address and attachment), saves dbc to s3 and populates dynamodb with metadata
4. convert dbc file and save to s3, populate dynamodb with metadata
5. send email back to requester with converted dbc file attached