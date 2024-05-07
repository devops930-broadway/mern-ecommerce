terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.46.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Creating an S3 Bucket
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "mern_fe" 
  force_destroy = true
}

# Creating S3 bucket website configuration
resource "aws_s3_bucket_website_configuration" "mern_fe_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.js"  
  }
}

# Uploading JavaScript File to S3 using aws_s3_object
resource "aws_s3_object" "index_js" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "index.js" 
  source       = "Mern-ecommerce-trail-project/client/app/index.js"  
  content_type = "application/javascript"  
}

# Creating CloudFront Distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_regional_domain_name
    origin_id   = "s3-cloudfront"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.js"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "s3-cloudfront"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_All"
  
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  wait_for_deployment = false

  tags = {
    Name        = "MyCloudFrontDistribution"
    Environment = "Production"
  }
  
  restrictions {
    geo_restriction {
    restriction_type = "none"
  }
  }
}

# Creating CloudFront Origin Access Identity

variable "domain_name" {
  type    = string
  default = ""  
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}

# Adding Bucket Policy
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.s3_bucket.id}/*"
    }
  ]
}
EOF
}
