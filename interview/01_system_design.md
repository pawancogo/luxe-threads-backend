# System Design Interview Guide

## Table of Contents
1. [Fundamentals](#fundamentals)
2. [Design Patterns](#design-patterns)
3. [Scalability Concepts](#scalability-concepts)
4. [Common System Design Questions](#common-system-design-questions)
5. [Interview Framework](#interview-framework)
6. [Practice Problems](#practice-problems)

## Fundamentals

### What is System Design?
System design is the process of defining the architecture, components, modules, interfaces, and data for a system to satisfy specified requirements.

### Key Principles
1. **Scalability**: System should handle increased load
2. **Reliability**: System should work consistently
3. **Availability**: System should be accessible when needed
4. **Performance**: System should respond quickly
5. **Maintainability**: System should be easy to modify
6. **Security**: System should protect data and resources

### Components of a System
- **Load Balancer**: Distributes incoming requests
- **Web Servers**: Handle HTTP requests
- **Application Servers**: Business logic processing
- **Database**: Data storage and retrieval
- **Cache**: Fast data access
- **CDN**: Content delivery network
- **Message Queue**: Asynchronous processing

## Design Patterns

### 1. Monolithic Architecture
```
Client → Load Balancer → Web Server → Application Server → Database
```

**Pros:**
- Simple to develop and deploy
- Easy to test
- Good for small applications

**Cons:**
- Hard to scale individual components
- Single point of failure
- Technology lock-in

### 2. Microservices Architecture
```
Client → API Gateway → Service A → Database A
                    → Service B → Database B
                    → Service C → Database C
```

**Pros:**
- Independent scaling
- Technology diversity
- Fault isolation

**Cons:**
- Complex deployment
- Network latency
- Data consistency challenges

### 3. Event-Driven Architecture
```
Producer → Message Queue → Consumer
```

**Use Cases:**
- Asynchronous processing
- Event sourcing
- CQRS (Command Query Responsibility Segregation)

## Scalability Concepts

### Horizontal vs Vertical Scaling

**Vertical Scaling (Scale Up):**
- Add more power (CPU, RAM) to existing machines
- Easier to implement
- Limited by hardware constraints

**Horizontal Scaling (Scale Out):**
- Add more machines to the system
- More complex but better long-term solution
- Requires load balancing

### Load Balancing Strategies

1. **Round Robin**: Distribute requests evenly
2. **Weighted Round Robin**: Assign weights to servers
3. **Least Connections**: Route to server with fewest active connections
4. **IP Hash**: Route based on client IP
5. **Geographic**: Route based on user location

### Database Scaling

**Read Replicas:**
```
Master DB → Read Replica 1
         → Read Replica 2
         → Read Replica 3
```

**Database Sharding:**
```
User ID 1-1000 → Shard 1
User ID 1001-2000 → Shard 2
User ID 2001-3000 → Shard 3
```

**Consistent Hashing:**
- Distributes data evenly across nodes
- Minimal data movement when nodes are added/removed

## Common System Design Questions

### 1. Design a URL Shortener (like bit.ly)

**Requirements:**
- Shorten long URLs
- Redirect to original URL
- Handle 100M URLs per day
- 5-year retention

**Design:**
```
Client → Load Balancer → Web Server → Application Server → Database
                                              ↓
                                        Cache (Redis)
```

**Key Components:**
- **URL Encoding**: Base62 encoding for short URLs
- **Database Schema**: 
  - `id` (auto-increment)
  - `original_url`
  - `short_url`
  - `created_at`
- **Cache**: Store frequently accessed URLs
- **Analytics**: Track click counts

### 2. Design a Chat System (like WhatsApp)

**Requirements:**
- 1:1 messaging
- Group messaging
- Message delivery status
- Handle 50M daily active users

**Design:**
```
Client → Load Balancer → Web Server → Message Service → Database
                                              ↓
                                        Message Queue
                                              ↓
                                        Push Notification Service
```

**Key Components:**
- **WebSocket**: Real-time communication
- **Message Queue**: Handle message delivery
- **Database**: Store messages and user data
- **Push Notifications**: Notify offline users

### 3. Design a Social Media Feed (like Twitter)

**Requirements:**
- Post tweets
- Follow users
- Timeline generation
- Handle 300M users

**Design:**
```
Client → Load Balancer → Web Server → Feed Service → Database
                                              ↓
                                        Cache (Redis)
                                              ↓
                                        Message Queue
```

**Key Components:**
- **Fan-out on Write**: Pre-compute timelines
- **Fan-out on Read**: Generate timelines on demand
- **Hybrid Approach**: Combine both strategies
- **Cache**: Store popular tweets and user timelines

### 4. Design a Video Streaming Service (like Netflix)

**Requirements:**
- Video upload and storage
- Video streaming
- Content recommendation
- Handle 200M users

**Design:**
```
Client → CDN → Load Balancer → Web Server → Application Server
                                              ↓
                                        Video Storage (S3)
                                              ↓
                                        Recommendation Engine
```

**Key Components:**
- **CDN**: Global content delivery
- **Video Encoding**: Multiple quality levels
- **Storage**: Distributed file system
- **Recommendation**: Machine learning algorithms

### 5. Design a Search Engine (like Google)

**Requirements:**
- Web crawling
- Indexing
- Search functionality
- Handle 8.5B searches per day

**Design:**
```
Crawler → Indexer → Search Index → Load Balancer → Search Service
                                              ↓
                                        Cache (Redis)
```

**Key Components:**
- **Web Crawler**: Discover and fetch web pages
- **Indexer**: Process and index content
- **Search Index**: Inverted index for fast retrieval
- **Ranking Algorithm**: PageRank, relevance scoring

## Interview Framework

### Step 1: Requirements Clarification
- **Functional Requirements**: What the system should do
- **Non-Functional Requirements**: Performance, scalability, availability
- **Scale**: Users, requests per second, data size
- **Constraints**: Budget, timeline, technology stack

### Step 2: High-Level Design
- **Architecture**: Overall system structure
- **Components**: Major system components
- **APIs**: Key interfaces and endpoints
- **Data Flow**: How data moves through the system

### Step 3: Detailed Design
- **Database Design**: Schema, indexing, partitioning
- **Caching Strategy**: What to cache, cache invalidation
- **Load Balancing**: How to distribute load
- **Security**: Authentication, authorization, data protection

### Step 4: Scale and Optimize
- **Bottlenecks**: Identify potential issues
- **Optimization**: Performance improvements
- **Monitoring**: System health and metrics
- **Failure Handling**: Error scenarios and recovery

## Practice Problems

### Beginner Level
1. Design a Pastebin (like pastebin.com)
2. Design a Rate Limiter
3. Design a Counter Service
4. Design a Notification System

### Intermediate Level
1. Design a Distributed Cache
2. Design a File Storage System
3. Design a Chat System
4. Design a Social Media Feed

### Advanced Level
1. Design a Distributed Database
2. Design a Real-time Analytics System
3. Design a Multi-player Game
4. Design a Global CDN

## Key Metrics to Consider

### Performance Metrics
- **Latency**: Time to process a request
- **Throughput**: Requests processed per second
- **Response Time**: Time to return a response

### Scalability Metrics
- **Concurrent Users**: Number of simultaneous users
- **Data Volume**: Amount of data stored
- **Request Rate**: Requests per second

### Reliability Metrics
- **Availability**: Percentage of uptime
- **MTBF**: Mean Time Between Failures
- **MTTR**: Mean Time To Recovery

## Common Pitfalls to Avoid

1. **Over-engineering**: Don't design for scale you don't need
2. **Single Point of Failure**: Always have redundancy
3. **Ignoring Security**: Consider authentication and authorization
4. **Poor Data Modeling**: Design database schema carefully
5. **No Monitoring**: Plan for observability from the start

## Resources for Further Learning

### Books
- "Designing Data-Intensive Applications" by Martin Kleppmann
- "System Design Interview" by Alex Xu
- "High Performance MySQL" by Baron Schwartz

### Online Resources
- [System Design Primer](https://github.com/donnemartin/system-design-primer)
- [Grokking the System Design Interview](https://www.educative.io/courses/grokking-the-system-design-interview)
- [High Scalability](http://highscalability.com/)

### Practice Platforms
- [LeetCode System Design](https://leetcode.com/explore/interview/card/system-design/)
- [Pramp System Design](https://www.pramp.com/)
- [InterviewBit System Design](https://www.interviewbit.com/system-design-interview-questions/)

## Interview Tips

1. **Start Simple**: Begin with basic design and iterate
2. **Ask Questions**: Clarify requirements before designing
3. **Think Out Loud**: Explain your thought process
4. **Consider Trade-offs**: Discuss pros and cons of decisions
5. **Be Realistic**: Design for actual scale, not theoretical limits
6. **Practice**: Solve problems regularly to build confidence

Remember: System design interviews are about demonstrating your ability to think through complex problems, not about knowing every detail. Focus on the process and reasoning behind your decisions.



