Epic 8: Media Service
US-8.1: Get Pre-signed Upload URL
As an owner
I want to upload images for my store, products, or collections
So that I can add visual content to my menu
Acceptance Criteria:

Owner can POST to /api/v1/media/upload-url
System accepts: {file_name: string, content_type: string}
System generates pre-signed S3 upload URL (valid for 15 minutes)
System returns: {upload_url: string, file_url: string}
Owner uploads directly to S3 using upload_url
Owner saves file_url in store/product/collection record

Technical Notes:

Endpoint: POST /api/v1/media/upload-url
Use AWS SDK to generate pre-signed PUT URL
Return both upload URL (for PUT) and final public URL
