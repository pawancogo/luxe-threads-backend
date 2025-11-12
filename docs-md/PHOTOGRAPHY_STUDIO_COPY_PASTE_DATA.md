# Photography Studio - Copy-Paste Data for Google Sheets

Copy and paste the data below directly into your Google Sheets. Each sheet should be created separately with the exact sheet name.

## Sheet 1: organization_profile

**Sheet Name:** `organization_profile`

**Format:** Entity-Value (Copy the entire table below and paste into Google Sheets)

```
entity	value
organization_name	Elegant Moments Photography Studio
tagline	Capturing Life's Precious Moments
description	With over 15 years of experience, we specialize in wedding photography, event coverage, and portrait sessions. Our team of professional photographers is dedicated to creating timeless memories that you'll treasure forever.
logo_url	https://example.com/logo.png
favicon_url	https://example.com/favicon.ico
contact_email	info@elegantmoments.com
contact_phone	+1-555-0123
contact_phone_alt	+1-555-0124
address_line1	123 Main Street
address_line2	Suite 100
city	New York
state	NY
zip_code	10001
country	United States
website_url	https://elegantmoments.com
social_facebook	https://facebook.com/elegantmoments
social_instagram	https://instagram.com/elegantmoments
social_twitter	https://twitter.com/elegantmoments
social_youtube	https://youtube.com/elegantmoments
social_linkedin	https://linkedin.com/company/elegantmoments
social_pinterest	https://pinterest.com/elegantmoments
business_hours_monday	9:00 AM - 6:00 PM
business_hours_tuesday	9:00 AM - 6:00 PM
business_hours_wednesday	9:00 AM - 6:00 PM
business_hours_thursday	9:00 AM - 6:00 PM
business_hours_friday	9:00 AM - 6:00 PM
business_hours_saturday	10:00 AM - 4:00 PM
business_hours_sunday	Closed
theme_id	elegant
layout_id	modern
google_maps_api_key	AIzaSy...
meta_title	Elegant Moments - Wedding Photography
meta_description	Professional wedding photography services for your special events
meta_keywords	wedding, photography, events
subscription_expiry_date	2025-12-31
copyright_text	© 2024 Elegant Moments Photography. All rights reserved.
footer_description	Capturing your special moments with professional photography services.
hero_title	Capturing Life's Precious Moments
hero_subtitle	Professional Photography Services for Your Special Events
hero_cta_primary	Book Now
hero_cta_secondary	View Portfolio
about_title	About Us
about_subtitle	Your Trusted Photography Partner
services_title	Our Services
services_subtitle	Comprehensive Photography Solutions
portfolio_title	Our Work
portfolio_subtitle	See Our Recent Projects
testimonials_title	What Our Clients Say
testimonials_subtitle	Trusted by Happy Customers
team_title	Meet Our Team
team_subtitle	Professional Photographers
contact_title	Get In Touch
contact_subtitle	We'd Love to Hear From You
booking_title	Check Availability
booking_subtitle	View Our Monthly Calendar
nav_home	Home
nav_services	Services
nav_portfolio	Portfolio
nav_team	Team
nav_packages	Packages
nav_blog	Blog
nav_about	About
nav_contact	Contact
nav_booking	Availability
footer_quick_links_title	Quick Links
footer_contact_title	Contact Us
footer_follow_title	Follow Us
button_read_more	Read More
button_view_all	View All
button_learn_more	Learn More
button_book_now	Book Now
button_contact_us	Contact Us
button_submit	Submit
button_send_message	Send Message
button_call_now	Call Now
button_email_us	Email Us
form_name_label	Name
form_email_label	Email
form_phone_label	Phone
form_message_label	Message
form_service_label	Service
form_date_label	Preferred Date
form_name_placeholder	Your Name
form_email_placeholder	your.email@example.com
form_phone_placeholder	+1 (555) 123-4567
form_message_placeholder	Tell us about your event...
form_success_message	Thank you! We'll get back to you within 24 hours.
form_error_message	Something went wrong. Please try again.
booking_note	For bookings, please call or email us
calendar_available_label	Available
calendar_booked_label	Booked
calendar_partial_label	Partially Available
calendar_unavailable_label	Unavailable
calendar_legend_title	Availability Status
calendar_month_nav_prev	Previous
calendar_month_nav_next	Next
no_results_message	No items found
loading_message	Loading...
error_404_title	Page Not Found
error_404_message	The page you're looking for doesn't exist.
error_404_button	Go Home
services_page_title	Our Services
services_page_description	Explore our comprehensive photography services
portfolio_page_title	Our Portfolio
portfolio_page_description	Browse through our recent work
team_page_title	Our Team
team_page_description	Meet our talented photographers
packages_page_title	Our Packages
packages_page_description	Choose the perfect package for your event
blog_page_title	Blog & News
blog_page_description	Latest tips, news, and updates
testimonials_page_title	Client Testimonials
testimonials_page_description	What our clients say about us
faq_page_title	Frequently Asked Questions
faq_page_description	Find answers to common questions
about_page_title	About Us
about_page_description	Learn more about our story
contact_page_title	Contact Us
contact_page_description	Get in touch with us
filter_all_label	All
filter_category_label	Category
search_placeholder	Search...
sort_label	Sort by
price_label	Price
duration_label	Duration
included_label	Includes
features_label	Features
related_label	Related
share_label	Share
read_time_label	min read
published_label	Published
author_label	Author
category_label	Category
tags_label	Tags
```

---

## Sheet 2: services

**Sheet Name:** `services`

```
id	name	slug	category	short_description	full_description	base_price	price_unit	price_note	duration	featured_image	gallery_images	included_items	is_featured	display_order	is_active
1	Wedding Photography	wedding-photography	Photography	Full-day wedding coverage	Our comprehensive wedding photography package includes pre-wedding consultation, full day coverage (8-10 hours), professional editing, online gallery, and USB drive with all high-resolution images. We capture every special moment from getting ready to the last dance.	2500	USD	Starting from	8-10 hours	https://example.com/wedding-service.jpg	https://example.com/w1.jpg,https://example.com/w2.jpg,https://example.com/w3.jpg	Pre-wedding consultation,Full day coverage,Online gallery,USB drive,50+ edited photos	TRUE	1	TRUE
2	Event Photography	event-photography	Photography	Professional event coverage	Perfect for corporate events, parties, and celebrations. Includes 4-6 hours of coverage, professional editing, and online gallery access.	1200	USD	Starting from	4-6 hours	https://example.com/event-service.jpg	https://example.com/e1.jpg,https://example.com/e2.jpg	Event coverage,Online gallery,30+ edited photos,Social media images	TRUE	2	TRUE
3	Portrait Sessions	portrait-sessions	Photography	Professional portrait photography	Individual, family, or group portrait sessions. Available in studio or outdoor locations. Includes 1-2 hour session and 20 edited high-resolution photos.	350	USD	Starting from	1-2 hours	https://example.com/portrait-service.jpg	https://example.com/p1.jpg,https://example.com/p2.jpg	1-2 hour session,20 edited photos,Online gallery,Print release	FALSE	3	TRUE
4	Corporate Photography	corporate-photography	Photography	Business and corporate photography	Professional headshots, team photos, and branded content for businesses. Perfect for websites, marketing materials, and company profiles.	800	USD	Starting from	2-4 hours	https://example.com/corporate-service.jpg	https://example.com/c1.jpg	Professional headshots,Team photos,Branded images,Online gallery	FALSE	4	TRUE
5	Drone Photography	drone-photography	Photography	Aerial photography and videography	Stunning aerial shots for weddings, events, and real estate. Includes FAA-licensed pilot and 4K video footage.	1500	USD	Starting from	2-3 hours	https://example.com/drone-service.jpg	https://example.com/d1.jpg	Aerial photography,4K video footage,Licensed pilot,Edited footage	FALSE	5	TRUE
```

---

## Sheet 3: portfolio

**Sheet Name:** `portfolio`

```
id	title	slug	category	subcategory	description	cover_image	images	video_url	location	event_date	client_name	featured	display_order	tags	is_active
1	Sarah & John's Garden Wedding	sarah-john-garden-wedding	Wedding	Outdoor Wedding	A beautiful outdoor wedding ceremony in a private garden, followed by an elegant reception. Captured every moment from the intimate ceremony to the lively celebration.	https://example.com/portfolio/wedding1-cover.jpg	https://example.com/portfolio/w1-1.jpg,https://example.com/portfolio/w1-2.jpg,https://example.com/portfolio/w1-3.jpg,https://example.com/portfolio/w1-4.jpg,https://example.com/portfolio/w1-5.jpg		Central Park, NYC	2024-06-15	Sarah & John	TRUE	1	outdoor,summer,romantic,garden	TRUE
2	Corporate Annual Gala	corporate-annual-gala	Corporate Event	Gala	Elegant corporate gala with 300+ attendees. Professional coverage of networking, dinner, and awards ceremony.	https://example.com/portfolio/corporate1-cover.jpg	https://example.com/portfolio/c1-1.jpg,https://example.com/portfolio/c1-2.jpg,https://example.com/portfolio/c1-3.jpg		Grand Ballroom, NYC	2024-05-20	TechCorp Inc.	TRUE	2	corporate,formal,elegant,gala	TRUE
3	Emily's Sweet 16 Birthday	emily-sweet-16	Birthday	Teen Party	Vibrant and fun Sweet 16 celebration with friends and family. Captured the energy and joy of this special milestone.	https://example.com/portfolio/birthday1-cover.jpg	https://example.com/portfolio/b1-1.jpg,https://example.com/portfolio/b1-2.jpg		Private Residence, Long Island	2024-07-10	Emily Rodriguez	FALSE	3	birthday,teen,fun,vibrant	TRUE
4	Michael & Lisa's Intimate Wedding	michael-lisa-intimate-wedding	Wedding	Intimate Wedding	A small, intimate wedding with 50 close friends and family. Focused on capturing the emotional moments and personal connections.	https://example.com/portfolio/wedding2-cover.jpg	https://example.com/portfolio/w2-1.jpg,https://example.com/portfolio/w2-2.jpg,https://example.com/portfolio/w2-3.jpg		Beachfront Resort, Malibu	2024-08-22	Michael & Lisa	TRUE	4	intimate,beach,romantic,small	TRUE
5	Product Launch Event	product-launch-event	Corporate Event	Product Launch	High-energy product launch event with live demonstrations, press coverage, and VIP guests.	https://example.com/portfolio/product1-cover.jpg	https://example.com/portfolio/p1-1.jpg,https://example.com/portfolio/p1-2.jpg	https://youtube.com/watch?v=example123	Convention Center, LA	2024-09-05	InnovateTech	FALSE	5	corporate,product launch,tech,modern	TRUE
6	Family Portrait Session - The Johnsons	family-portrait-johnsons	Portrait	Family Portrait	Beautiful family portrait session in a local park during golden hour. Captured natural, candid moments of a family of five.	https://example.com/portfolio/portrait1-cover.jpg	https://example.com/portfolio/pt1-1.jpg,https://example.com/portfolio/pt1-2.jpg,https://example.com/portfolio/pt1-3.jpg		Riverside Park, NYC	2024-06-30	The Johnson Family	FALSE	6	family,portrait,outdoor,natural	TRUE
```

---

## Sheet 4: team

**Sheet Name:** `team`

```
id	name	role	bio	profile_image	email	phone	social_instagram	social_facebook	social_linkedin	specialties	years_experience	display_order	is_active
1	Michael Chen	Lead Photographer	Michael has over 10 years of experience in wedding and event photography. His artistic eye and attention to detail have earned him numerous awards. He specializes in capturing authentic, emotional moments.	https://example.com/team/michael.jpg	michael@elegantmoments.com	+1-555-0125	https://instagram.com/michaelchenphoto	https://facebook.com/michaelchenphoto	https://linkedin.com/in/michaelchenphoto	Wedding,Portrait,Commercial	10	1	TRUE
2	Sarah Martinez	Senior Photographer	Sarah brings a creative and modern approach to photography. With 8 years of experience, she excels at capturing candid moments and creating stunning visual narratives.	https://example.com/team/sarah.jpg	sarah@elegantmoments.com	+1-555-0126	https://instagram.com/sarahmartinezphoto		https://linkedin.com/in/sarahmartinezphoto	Wedding,Event,Portrait	8	2	TRUE
3	David Kim	Drone Specialist	David is our FAA-licensed drone pilot and aerial photography specialist. He creates breathtaking aerial shots and videos for weddings and events.	https://example.com/team/david.jpg	david@elegantmoments.com	+1-555-0127	https://instagram.com/davidkimdrone		https://linkedin.com/in/davidkimdrone	Drone Photography,Aerial Videography	5	3	TRUE
4	Jennifer Lee	Event Coordinator	Jennifer ensures every event runs smoothly. With 12 years of experience in event planning and coordination, she handles all the details so you can enjoy your special day.	https://example.com/team/jennifer.jpg	jennifer@elegantmoments.com	+1-555-0128	https://instagram.com/jenniferleeevents		https://linkedin.com/in/jenniferleeevents	Event Planning,Coordination	12	4	TRUE
5	Robert Taylor	Second Shooter	Robert is an experienced second photographer who ensures no moment is missed. He specializes in capturing different angles and candid moments throughout the event.	https://example.com/team/robert.jpg	robert@elegantmoments.com	+1-555-0129	https://instagram.com/roberttaylorphoto			Wedding,Event	6	5	TRUE
```

---

## Sheet 5: testimonials

**Sheet Name:** `testimonials`

```
id	client_name	client_image	event_type	rating	testimonial_text	event_date	featured	display_order	is_active
1	Emily Rodriguez	https://example.com/testimonials/emily.jpg	Wedding	5	Absolutely amazing experience! Michael and his team captured every moment of our special day perfectly. The photos are stunning and we couldn't be happier. Highly recommend!	2024-06-15	TRUE	1	TRUE
2	James Wilson		Corporate Event	5	Professional, punctual, and the photos exceeded our expectations. The team was easy to work with and delivered high-quality results for our annual gala.	2024-05-20	TRUE	2	TRUE
3	Maria Garcia	https://example.com/testimonials/maria.jpg	Portrait Session	5	Sarah did an incredible job with our family portraits. She made us all feel comfortable and captured beautiful, natural moments. The photos are treasures we'll have forever.	2024-06-30	TRUE	3	TRUE
4	Thomas Anderson		Wedding	5	From the initial consultation to the final delivery, everything was seamless. The attention to detail and artistic vision is outstanding. Worth every penny!	2024-08-22	FALSE	4	TRUE
5	Lisa Park	https://example.com/testimonials/lisa.jpg	Event	4	Great service and beautiful photos. The team was professional and the turnaround time was impressive. Would definitely book again for future events.	2024-07-10	FALSE	5	TRUE
6	Robert Brown		Corporate Event	5	Excellent corporate photography services. The team understood our brand and delivered images that perfectly represent our company. Highly professional!	2024-09-05	FALSE	6	TRUE
```

---

## Sheet 6: packages

**Sheet Name:** `packages`

```
id	name	slug	service_id	description	price	price_unit	original_price	duration	featured_image	included_services	features	is_popular	is_active	display_order
1	Premium Wedding Package	premium-wedding-package	1	Complete wedding photography solution with everything you need for your special day.	5000	USD	6000	Full Day	https://example.com/packages/premium.jpg	Pre-wedding shoot,Wedding day,Post-wedding	2 Photographers,Drone footage,Photo album,USB drive,Online gallery,Engagement session	TRUE	TRUE	1
2	Standard Wedding Package	standard-wedding-package	1	Essential wedding photography coverage for your special day.	3000	USD		Full Day	https://example.com/packages/standard.jpg	Wedding day	1 Photographer,Online gallery,USB drive,50+ edited photos	FALSE	TRUE	2
3	Deluxe Event Package	deluxe-event-package	2	Comprehensive event coverage with multiple photographers and video.	2500	USD	3000	Full Day	https://example.com/packages/deluxe-event.jpg	Event coverage	2 Photographers,Video coverage,Online gallery,Social media images	TRUE	TRUE	3
4	Family Portrait Package	family-portrait-package	3	Perfect for families wanting professional portraits.	450	USD		2 hours	https://example.com/packages/family.jpg	Portrait session	1-2 hour session,20 edited photos,Online gallery,Print release	FALSE	TRUE	4
5	Corporate Essentials	corporate-essentials	4	Professional corporate photography for businesses.	1200	USD		Half Day	https://example.com/packages/corporate.jpg	Corporate photography	Headshots,Team photos,Branded images,Online gallery	FALSE	TRUE	5
```

---

## Sheet 7: blog

**Sheet Name:** `blog`

```
id	title	slug	excerpt	content	author	featured_image	category	tags	publish_date	is_featured	is_published	display_order
1	10 Tips for Perfect Wedding Photos	10-tips-perfect-wedding-photos	Planning your wedding? Here are 10 essential tips to ensure your wedding photos turn out absolutely stunning.	<p>Your wedding day is one of the most important days of your life, and you want the photos to be perfect. Here are our top 10 tips:</p><ol><li>Plan your timeline carefully</li><li>Choose the right photographer</li><li>Consider the lighting</li><li>Trust your photographer</li><li>Be yourself</li><li>Plan for golden hour</li><li>Have a backup plan for weather</li><li>Get engagement photos first</li><li>Create a shot list</li><li>Relax and enjoy the moment</li></ol>	Michael Chen	https://example.com/blog/wedding-tips.jpg	Wedding Tips	wedding,photography,tips,planning	2024-06-01	TRUE	TRUE	1
2	How to Choose the Right Event Venue	how-to-choose-right-event-venue	Selecting the perfect venue is crucial for your event's success. Here's what to consider.	<p>Choosing the right venue can make or break your event. Consider these factors:</p><ul><li>Capacity and space</li><li>Location and accessibility</li><li>Amenities and services</li><li>Budget considerations</li><li>Availability and booking</li></ul>	Jennifer Lee	https://example.com/blog/venue-selection.jpg	Event Planning	venue,event planning,wedding,corporate	2024-07-15	TRUE	TRUE	2
3	The Art of Portrait Photography	art-of-portrait-photography	Learn the secrets behind creating stunning portrait photographs that capture personality and emotion.	<p>Portrait photography is about more than just taking a picture - it's about capturing the essence of a person. Here's how we approach it...</p>	Sarah Martinez	https://example.com/blog/portrait-art.jpg	Photography Tips	portrait,photography,technique,art	2024-08-01	FALSE	TRUE	3
4	Drone Photography: A New Perspective	drone-photography-new-perspective	Discover how drone photography is revolutionizing event coverage and creating stunning aerial perspectives.	<p>Drone photography has opened up entirely new possibilities for capturing events. From breathtaking aerial shots of wedding venues to dynamic corporate event coverage...</p>	David Kim	https://example.com/blog/drone-perspective.jpg	Photography Technology	drone,photography,technology,aerial	2024-09-10	FALSE	TRUE	4
```

---

## Sheet 8: venue_info

**Sheet Name:** `venue_info`

```
entity	value
venue_name	Grand Ballroom Events
capacity_min	50
capacity_max	500
venue_type	Ballroom
amenities	Parking,WiFi,Catering,Stage,Sound System,Lighting,Projector,Bar Service,Restrooms,Air Conditioning
room_count	3
parking_spaces	100
venue_images	https://example.com/venue/ballroom1.jpg,https://example.com/venue/ballroom2.jpg,https://example.com/venue/ballroom3.jpg
floor_plan_image	https://example.com/venue/floorplan.jpg
virtual_tour_url	https://example.com/virtual-tour/ballroom
booking_contact_email	bookings@venue.com
booking_contact_phone	+1-555-0201
deposit_percentage	30
cancellation_policy	Full refund 30 days before event, 50% refund 14 days before, no refund within 7 days
venue_title	Our Venue
venue_subtitle	Perfect Space for Your Event
capacity_label	Capacity
amenities_label	Amenities
rooms_label	Rooms
parking_label	Parking Spaces
```

---

## Sheet 9: booking_availability

**Sheet Name:** `booking_availability`

```
id	date	status	service_id	notes	event_name
1	2024-10-15	available			 
2	2024-10-16	available			 
3	2024-10-17	available			 
4	2024-10-18	booked	1		Sarah & John Wedding
5	2024-10-19	partial	3	Morning slot available	 
6	2024-10-20	available			 
7	2024-10-21	booked	2		Corporate Gala Event
8	2024-10-22	available			 
9	2024-10-23	partial	1	Afternoon available	 
10	2024-10-24	available			 
11	2024-10-25	booked	1		Emily's Sweet 16
12	2024-10-26	available			 
13	2024-10-27	unavailable		Holiday - Closed	 
14	2024-10-28	available			 
15	2024-10-29	booked	1		Michael & Lisa Wedding
16	2024-10-30	available			 
17	2024-10-31	partial	2	Evening available	 
18	2024-11-01	available			 
19	2024-11-02	booked	1		Product Launch Event
20	2024-11-03	available			 
21	2024-12-25	unavailable		Christmas - Closed	 
22	2024-12-31	booked	2		New Year's Eve Celebration
```

---

## Sheet 10: faq

**Sheet Name:** `faq`

```
id	question	answer	category	display_order	is_active
1	How far in advance should I book?	We recommend booking 3-6 months in advance, especially for weddings and popular dates. However, we can sometimes accommodate last-minute bookings depending on availability.	Booking	1	TRUE
2	What is included in the wedding photography package?	Our standard package includes 8-10 hours of coverage, online gallery, USB drive with all high-resolution images, and professional editing. Premium packages include additional services like engagement sessions and photo albums.	Services	2	TRUE
3	Do you provide raw/unedited photos?	We provide professionally edited high-resolution images. Raw files are available upon request for an additional fee.	Services	3	TRUE
4	Can I customize a package?	Yes! We're happy to customize packages to fit your specific needs and budget. Contact us to discuss your requirements.	Booking	4	TRUE
5	What is your cancellation policy?	Full refund available 30 days before the event, 50% refund 14 days before, no refund within 7 days of the event.	Booking	5	TRUE
6	Do you travel for events?	Yes, we travel for events. Travel fees may apply for locations outside our standard service area. Contact us for a quote.	Services	6	TRUE
7	How long until I receive my photos?	Typically, you'll receive your photos within 2-4 weeks after the event. Rush delivery is available for an additional fee.	Services	7	TRUE
8	Do you offer video services?	Yes, we offer videography services. Video packages can be added to photography packages or booked separately.	Services	8	TRUE
9	What payment methods do you accept?	We accept credit cards, bank transfers, and checks. A deposit is required to secure your booking.	Booking	9	TRUE
10	Can I see examples of your work?	Absolutely! Check out our portfolio page to see examples of our work across different event types.	General	10	TRUE
```

---

## Sheet 11: theme_config

**Sheet Name:** `theme_config`

```
entity	value
theme_id	elegant
theme_name	Elegant
primary_color	#8B5A3C
secondary_color	#D4AF37
accent_color	#F5E6D3
background_color	#FFFFFF
text_primary	#1A1A1A
text_secondary	#666666
font_heading	Playfair Display
font_body	Lato
border_radius	8px
spacing_unit	8px
layout_style	modern
header_style	sticky
footer_style	minimal
```

---

## Instructions for Setting Up Google Sheets

1. **Create a new Google Sheet**
2. **Create 11 separate sheets** with these exact names:
   - `organization_profile`
   - `services`
   - `portfolio`
   - `team`
   - `testimonials`
   - `packages`
   - `blog`
   - `venue_info`
   - `booking_availability`
   - `faq`
   - `theme_config`

3. **For each sheet:**
   - Copy the header row (first line) and paste it in row 1
   - Copy the data rows and paste starting from row 2
   - Make sure the sheet is set to "Anyone with the link can view" (for public access)

4. **Get your Sheet ID:**
   - The Sheet ID is in the URL: `https://docs.google.com/spreadsheets/d/[SHEET_ID]/edit`
   - Copy the `[SHEET_ID]` part

5. **Set up Google Sheets API:**
   - Go to Google Cloud Console
   - Enable Google Sheets API
   - Create an API key
   - Add the API key to your environment variables

6. **Set Environment Variables:**
   ```
   NEXT_PUBLIC_GOOGLE_SHEETS_API_KEY=your_api_key_here
   NEXT_PUBLIC_GOOGLE_SHEET_ID=your_sheet_id_here
   NEXT_PUBLIC_SUBSCRIPTION_EXPIRY_DATE=2025-12-31
   ```

---

## Notes

- All data is tab-separated - copy and paste directly into Google Sheets
- Empty cells are represented by a single space or can be left blank
- Dates should be in YYYY-MM-DD format
- Boolean values use TRUE/FALSE (all caps)
- Image URLs can be updated to your actual image URLs
- The subscription expiry date in `organization_profile` should match your environment variable

