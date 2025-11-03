// Dummy data used across the UI. Replace or extend with backend data later.

const List<Map<String, dynamic>> sampleCategories = [
  {"id": "c1", "name": "Clothing", "icon": "dress"},
  {"id": "c2", "name": "Groceries", "icon": "local_grocery_store"},
  {"id": "c3", "name": "Electronics", "icon": "tv"},
  {"id": "c4", "name": "Medical", "icon": "local_hospital"},
  {"id": "c5", "name": "Vehicles", "icon": "directions_car"},
];

const List<Map<String, dynamic>> sampleOffers = [
  {
    "id": "o1",
    "title": "Flat 40% off on Summer Collection",
    "category": "Clothing",
    "price": 1200,
    "discount": "40%",
    "store": "Moda Boutique",
    "city": "Bengaluru",
    "image": "assets/images/offer1.jpg",
    "expiry": "2025-12-31",
    "location": {"lat": 12.9716, "lng": 77.5946},
  },
  {
    "id": "o2",
    "title": "Buy 1 Get 1 Free - Organic Vegetables",
    "category": "Groceries",
    "price": 250,
    "discount": "B1G1",
    "store": "GreenFresh",
    "city": "Mumbai",
    "image": "assets/images/offer2.jpg",
    "expiry": "2025-11-30",
    "location": {"lat": 19.0760, "lng": 72.8777},
  },
  {
    "id": "o3",
    "title": "Up to 25% off on Electronics",
    "category": "Electronics",
    "price": 54000,
    "discount": "25%",
    "store": "Tech World",
    "city": "Delhi",
    "image": "assets/images/offer3.jpg",
    "expiry": "2025-10-15",
    "location": {"lat": 28.7041, "lng": 77.1025},
  },
];
