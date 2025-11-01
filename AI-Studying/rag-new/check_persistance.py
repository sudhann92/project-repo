# Task 6: Test Database Persistence

# Let's test the persistence of our vector database! The check script will:

# Not add anything - Will not add any new entry to the database
# Reads from the persistent database - Read the entry done in the database using the save script in the previous task
# Test the vector database contents to demonstrate persistence:

from chromadb import PersistentClient

# Connect to the persistent DB at the specified path
client = PersistentClient(path="./chroma_db")
collection = client.get_or_create_collection("techcorp_docs")

# Print count of documents in the collection
print("📊 Document count:", collection.count())

# Print all documents in the collection
results = collection.get()
for i, doc in enumerate(results["documents"], 1):
    print(f"{i}. {doc}")



# ~/rag-project ➜  uv run python check_persistence.py 
# 📊 Document count: 4
# 1. TechCorp allows remote work up to 3 days per week
# 2. Employees can bring pets to work on Fridays
# 3. Company provides health insurance and dental coverage
# 4. Remote workers must use approved equipment