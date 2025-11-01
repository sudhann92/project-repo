# Task 2: Why Document Chunking Matters

# 📄 View the script - chunking_problem_demo.py to see how it works

# What this demo shows:
# This script demonstrates the core problem with searching large documents in RAG systems. It creates a sample employee handbook and shows how searching for specific information (like 'internet speed requirements') returns the entire document instead of just the relevant section.

# What you'll see:

# A large document stored as a single chunk
# Search queries that should find specific sections
# Results that return the entire document (the problem!)
# Clear explanation of why this is problematic for RAG
# Run this command to see the chunking problem:

#!/usr/bin/env python3
"""
Chunking Problem Demo
Shows why document chunking is essential for RAG systems
"""

import chromadb

print("✂️ Document Chunking Problem Demo")
print("=" * 40)

# Initialize ChromaDB and model
client = chromadb.Client()
collection = client.create_collection("policies")

print(collection)
# Create a large document
large_document = """
TechCorp Employee Handbook - Remote Work Policy

Section 1: Eligibility and Approval Process
Employees may work remotely up to 3 days per week with manager approval. 
Remote work days must be scheduled in advance and approved by your direct supervisor.

Section 2: Equipment and Technology Requirements
Remote employees must have a secure and reliable internet connection with minimum speeds of 25 Mbps download and 5 Mbps upload.
All work must be performed on company-approved devices and software.
Personal devices are not permitted for work purposes.

Section 3: Workspace and Environment Standards
Remote work is not a substitute for childcare or eldercare responsibilities.
Employees must have a dedicated workspace free from distractions.
The workspace must be professional and suitable for video calls.

Section 4: Performance and Evaluation
Performance evaluations will be conducted quarterly.
Remote work performance will be assessed based on deliverables and communication.
"""

# Store the large document as a single chunk
collection.add(
    documents=[large_document],
    ids=["large_document"]
)

print("🔍 Searching for: 'internet speed requirements'")
print()

# Search for specific information
results = collection.query(
    query_texts=["internet speed requirements"],
    n_results=1
)

result_text = results['documents'][0][0]
print("❌ Problem: Returns entire document!")
print(f"Result: {result_text[:200]}...")
print()
print("💡 Solution: Break document into chunks!")
print("✅ Each chunk contains specific information")
print("✅ Better search precision")

# Create completion marker
with open("chunking_problem_complete.txt", "w") as f:
    f.write("Chunking problem demo completed")
