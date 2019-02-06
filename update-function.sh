cd /Users/eddys/git/extract-attachment
zip -g lambda_function.py
aws lambda update-function-code --function-name extract-attachment --zip-file fileb://dbc-converter.zip --profile intapp-devopssbx_eddy.snow@intapp.com --region eu-west-1
