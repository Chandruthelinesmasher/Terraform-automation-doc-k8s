# Step 1: Use an official Nginx image as base
FROM nginx:alpine

# Step 2: Copy website files to Nginx web root
COPY ../2147_titan_folio /usr/share/nginx/html

# Step 3: Expose port 80
EXPOSE 80

# Step 4: Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
