package s3

import (
	"context"
	"fmt"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

type S3Client struct {
	client     *s3.Client
	bucketName string
}

// NewS3Client creates a new S3 client
// For local development, it can use MinIO or LocalStack
func NewS3Client(region, bucketName, endpoint, accessKey, secretKey string, usePathStyle bool) (*S3Client, error) {
	var cfg aws.Config
	var err error

	if endpoint != "" {
		// Local development with MinIO or LocalStack
		cfg, err = config.LoadDefaultConfig(context.TODO(),
			config.WithRegion(region),
			config.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(accessKey, secretKey, "")),
		)
		if err != nil {
			return nil, fmt.Errorf("failed to load AWS config: %w", err)
		}

		client := s3.NewFromConfig(cfg, func(o *s3.Options) {
			o.BaseEndpoint = aws.String(endpoint)
			o.UsePathStyle = usePathStyle
		})

		return &S3Client{
			client:     client,
			bucketName: bucketName,
		}, nil
	}

	// Production: Use default AWS configuration
	cfg, err = config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)
	if err != nil {
		return nil, fmt.Errorf("failed to load AWS config: %w", err)
	}

	client := s3.NewFromConfig(cfg)

	return &S3Client{
		client:     client,
		bucketName: bucketName,
	}, nil
}

// GeneratePresignedUploadURL generates a pre-signed URL for uploading a file
func (c *S3Client) GeneratePresignedUploadURL(fileName, contentType string, expiryMinutes int) (string, error) {
	presignClient := s3.NewPresignClient(c.client)

	request, err := presignClient.PresignPutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(c.bucketName),
		Key:         aws.String(fileName),
		ContentType: aws.String(contentType),
	}, func(opts *s3.PresignOptions) {
		opts.Expires = time.Duration(expiryMinutes) * time.Minute
	})

	if err != nil {
		return "", fmt.Errorf("failed to generate presigned URL: %w", err)
	}

	return request.URL, nil
}

// GetFileURL returns the public URL for a file
func (c *S3Client) GetFileURL(fileName string) string {
	// For local development with MinIO/LocalStack
	if c.client.Options().BaseEndpoint != nil {
		return fmt.Sprintf("%s/%s/%s", *c.client.Options().BaseEndpoint, c.bucketName, fileName)
	}

	// For AWS S3
	return fmt.Sprintf("https://%s.s3.%s.amazonaws.com/%s", c.bucketName, c.client.Options().Region, fileName)
}
