import React, { useState, useEffect } from 'react';

const API_BASE = '/api';

function App() {
  const [activeTab, setActiveTab] = useState('neighborhood');
  const [houses, setHouses] = useState([]);
  const [neighborhood, setNeighborhood] = useState(null);
  const [addonTypes, setAddonTypes] = useState({});
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  
  // Form states
  const [newHouseOwner, setNewHouseOwner] = useState('');
  const [newHouseName, setNewHouseName] = useState('');
  const [selectedHouse, setSelectedHouse] = useState(null);
  const [selectedAddonType, setSelectedAddonType] = useState('');

  useEffect(() => {
    loadData();
  }, []);

  const loadData = async () => {
    try {
      setLoading(true);
      const [housesRes, neighborhoodRes, addonTypesRes] = await Promise.all([
        fetch(`${API_BASE}/houses`),
        fetch(`${API_BASE}/neighborhood`),
        fetch(`${API_BASE}/addon-types`)
      ]);
      
      const housesData = await housesRes.json();
      const neighborhoodData = await neighborhoodRes.json();
      const addonTypesData = await addonTypesRes.json();
      
      setHouses(housesData);
      setNeighborhood(neighborhoodData);
      setAddonTypes(addonTypesData);
    } catch (err) {
      setError('Failed to load data: ' + err.message);
    } finally {
      setLoading(false);
    }
  };

  const createHouse = async (e) => {
    e.preventDefault();
    try {
      setError(null);
      const response = await fetch(`${API_BASE}/houses`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          owner: newHouseOwner,
          name: newHouseName || undefined
        })
      });
      
      if (!response.ok) throw new Error('Failed to create house');
      
      setSuccess(`✅ Created house for ${newHouseOwner}!`);
      setNewHouseOwner('');
      setNewHouseName('');
      loadData();
      
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Failed to create house: ' + err.message);
    }
  };

  const buildAddon = async (e) => {
    e.preventDefault();
    if (!selectedHouse || !selectedAddonType) return;
    
    try {
      setError(null);
      const response = await fetch(`${API_BASE}/houses/${selectedHouse}/addons`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: selectedAddonType })
      });
      
      if (!response.ok) throw new Error('Failed to build addon');
      
      const addon = await response.json();
      setSuccess(`✅ Built ${addon.name}!`);
      setSelectedHouse(null);
      setSelectedAddonType('');
      loadData();
      
      setTimeout(() => setSuccess(null), 3000);
    } catch (err) {
      setError('Failed to build addon: ' + err.message);
    }
  };

  if (loading) {
    return <div className="loading">🏠 Loading Valley Town...</div>;
  }

  return (
    <div className="container">
      <header className="header">
        <h1>🏠 EXX - House & Addon System</h1>
        <p>Stardew Valley-inspired management for your EV CLI</p>
      </header>

      {error && <div className="error">{error}</div>}
      {success && <div className="success">{success}</div>}

      <div className="tabs">
        <button 
          className={`tab-button ${activeTab === 'neighborhood' ? 'active' : ''}`}
          onClick={() => setActiveTab('neighborhood')}
        >
          🏘️ Neighborhood
        </button>
        <button 
          className={`tab-button ${activeTab === 'create' ? 'active' : ''}`}
          onClick={() => setActiveTab('create')}
        >
          ➕ Create House
        </button>
        <button 
          className={`tab-button ${activeTab === 'build' ? 'active' : ''}`}
          onClick={() => setActiveTab('build')}
        >
          🔨 Build Addon
        </button>
        <button 
          className={`tab-button ${activeTab === 'addons' ? 'active' : ''}`}
          onClick={() => setActiveTab('addons')}
        >
          📦 Addon Types
        </button>
      </div>

      {activeTab === 'neighborhood' && (
        <div className="card">
          <h2>🏘️ {neighborhood?.name || 'Valley Town'}</h2>
          <div className="stats">
            <div className="stat-item">
              <strong>{houses.length}</strong>
              <span>Houses</span>
            </div>
            <div className="stat-item">
              <strong>{houses.reduce((sum, h) => sum + (h.addons?.length || 0), 0)}</strong>
              <span>Total Addons</span>
            </div>
          </div>
          
          <div className="grid">
            {neighborhood?.housesData?.map(house => (
              <div key={house.id} className="house-card">
                <h3>🏠 {house.name}</h3>
                <p><strong>Owner:</strong> {house.owner}</p>
                <p><strong>ID:</strong> {house.id}</p>
                <p><strong>Created:</strong> {new Date(house.createdAt).toLocaleDateString()}</p>
                
                {house.addonsData && house.addonsData.length > 0 ? (
                  <div style={{ marginTop: '1rem' }}>
                    <strong>Addons:</strong>
                    <div style={{ marginTop: '0.5rem', display: 'flex', flexWrap: 'wrap', gap: '0.5rem' }}>
                      {house.addonsData.map(addon => (
                        <span key={addon.id} className="badge">
                          {addon.icon} {addon.name}
                        </span>
                      ))}
                    </div>
                  </div>
                ) : (
                  <p style={{ marginTop: '1rem', color: '#999' }}>No addons yet</p>
                )}
                
                {house.neighbors && house.neighbors.length > 0 && (
                  <div className="neighbors">
                    <h4>👥 Neighbors:</h4>
                    <div className="neighbor-list">
                      {house.neighbors.map(neighbor => (
                        <span key={neighbor.id} className="neighbor-badge">
                          {neighbor.owner}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {activeTab === 'create' && (
        <div className="card">
          <h2>➕ Create New House</h2>
          <p style={{ marginBottom: '2rem', color: '#666' }}>
            Your EV CLI IS your house. It stores all your data, logs, and runs.
          </p>
          
          <form onSubmit={createHouse}>
            <div className="form-group">
              <label htmlFor="owner">Owner Name *</label>
              <input
                id="owner"
                type="text"
                value={newHouseOwner}
                onChange={(e) => setNewHouseOwner(e.target.value)}
                placeholder="Enter owner name"
                required
              />
            </div>
            
            <div className="form-group">
              <label htmlFor="name">House Name (optional)</label>
              <input
                id="name"
                type="text"
                value={newHouseName}
                onChange={(e) => setNewHouseName(e.target.value)}
                placeholder="e.g., Alice's Dev House"
              />
            </div>
            
            <button type="submit" className="button">
              🏠 Create House
            </button>
          </form>
        </div>
      )}

      {activeTab === 'build' && (
        <div className="card">
          <h2>🔨 Build Addon</h2>
          <p style={{ marginBottom: '2rem', color: '#666' }}>
            Expand your house with addons to add functionality.
          </p>
          
          <form onSubmit={buildAddon}>
            <div className="form-group">
              <label htmlFor="house">Select House *</label>
              <select
                id="house"
                value={selectedHouse || ''}
                onChange={(e) => setSelectedHouse(e.target.value)}
                required
              >
                <option value="">Choose a house...</option>
                {houses.map(house => (
                  <option key={house.id} value={house.id}>
                    {house.name} ({house.owner})
                  </option>
                ))}
              </select>
            </div>
            
            <div className="form-group">
              <label htmlFor="addon">Addon Type *</label>
              <select
                id="addon"
                value={selectedAddonType}
                onChange={(e) => setSelectedAddonType(e.target.value)}
                required
              >
                <option value="">Choose addon type...</option>
                {Object.entries(addonTypes).map(([key, type]) => (
                  <option key={key} value={key}>
                    {type.icon} {type.name} - {type.category}
                  </option>
                ))}
              </select>
            </div>
            
            {selectedAddonType && addonTypes[selectedAddonType] && (
              <div style={{ 
                padding: '1rem', 
                background: '#f5f5f5', 
                borderRadius: '8px', 
                marginBottom: '1rem' 
              }}>
                <h4>{addonTypes[selectedAddonType].icon} {addonTypes[selectedAddonType].name}</h4>
                <p style={{ color: '#666', margin: '0.5rem 0' }}>
                  {addonTypes[selectedAddonType].description}
                </p>
                <p style={{ fontSize: '0.9rem', color: '#999' }}>
                  <strong>Provides:</strong> {addonTypes[selectedAddonType].provides.join(', ')}
                </p>
              </div>
            )}
            
            <button type="submit" className="button" disabled={!selectedHouse || !selectedAddonType}>
              🔨 Build Addon
            </button>
          </form>
        </div>
      )}

      {activeTab === 'addons' && (
        <div className="card">
          <h2>📦 Available Addon Types</h2>
          <p style={{ marginBottom: '2rem', color: '#666' }}>
            Expand your house with these addon types.
          </p>
          
          <div className="addon-grid">
            {Object.entries(addonTypes).map(([key, type]) => (
              <div key={key} className="addon-card">
                <h4>{type.icon} {type.name}</h4>
                <span className="category">{type.category}</span>
                <p style={{ marginTop: '0.5rem' }}>{type.description}</p>
                <p style={{ fontSize: '0.85rem', color: '#555', marginTop: '0.5rem' }}>
                  <strong>Provides:</strong>
                </p>
                <ul style={{ fontSize: '0.85rem', color: '#666', paddingLeft: '1.5rem' }}>
                  {type.provides.map((item, i) => (
                    <li key={i}>{item}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
