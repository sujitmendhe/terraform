provider "aws" {
  
}


resource "aws_iam_role" "lambda_role" {
    name = "lambda_execution_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
  
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  
}

resource "aws_s3_bucket" "bucketname" {
    bucket = "mylambdas3testload11111111111111"

}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.bucketname.bucket
  key    = "lambda_function.zip"
  source = data.archive_file.lambda_zip.output_path
  etag   = filemd5(data.archive_file.lambda_zip.output_path)
}

resource "aws_lambda_function" "my_lambda" {
    function_name = "my_lambda_function"
    role = aws_iam_role.lambda_role.arn
    handler = "lambda_function.lambda_handler"
    runtime = "python3.12"
    timeout = 900
    memory_size = 128

#    filename = "lambda_function_zip"
#    source_code_hash = filebase64sha256("lambda_function.zip")
    s3_bucket = aws_s3_bucket.bucketname.bucket
    s3_key = aws_s3_object.lambda_zip.key
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}