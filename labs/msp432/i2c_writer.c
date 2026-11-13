#include "i2c_common.h"
const uint8_t PACKET[] = {RTC_REG_ADDR, 0xAA, 0xBB, 0xCC};
const size_t PACKET_LEN = sizeof(PACKET) / sizeof(PACKET[0]);

static void init_i2c() {
  // SDA_PIN and SCK_PIN get {SEL1,SEL0}=Primary Module Function (e.g. I2C)
  P1->SEL0 |= SDA_PIN | SCK_PIN;
  P1->SEL1 &= ~(SDA_PIN | SCK_PIN);

  // SW reset while configuring I2C
  EUSCI_B0->CTLW0  = EUSCI_B_CTLW0_SWRST;
  EUSCI_B0->CTLW0 |= EUSCI_B_CTLW0_UCSSEL_3 // SMCLK (6 MHz)
                     | EUSCI_B_CTLW0_MODE_3 // I2C Mode
                     | EUSCI_B_CTLW0_MST    // Master Mode
                     | EUSCI_B_CTLW0_TR;    // Transmitter (writer) Mode

  // Baud Rate = SMCLK / 60 = 100 kHz
  EUSCI_B0->BRW = 60;

  // Set the I2C Slave Address
  EUSCI_B0->I2CSA = RTC_SLAVE_ADDR;

  // Auto-Stop Mode
  EUSCI_B0->CTLW1 = EUSCI_B_CTLW1_ASTP_2;
  EUSCI_B0->TBCNT = PACKET_LEN; // STOP after transmitter PACKET_LEN bytes

  // Release SW reset
  EUSCI_B0->CTLW0 &= ~EUSCI_B_CTLW0_SWRST;
}

int main() {
  WDT_A->CTL = WDT_A_CTL_PW | WDT_A_CTL_HOLD; // Stop the WatchDog Timer

  init_i2c();

  // Enable TX interrupt
  EUSCI_B0->IE |= EUSCI_B_IE_TXIE0;
  NVIC_EnableIRQ(EUSCIB0_IRQn);
  __enable_irq(); // enable global interrupt

  while (1) {
    // Generate START condition to begin transmission
    EUSCI_B0->CTLW0 |= EUSCI_B_CTLW0_TXSTT;
    // Wait until transmission finishes
    while (!(EUSCI_B0->IFG & EUSCI_B_IFG_STPIFG));
    EUSCI_B0->IFG &= ~EUSCI_B_IFG_STPIFG;

    // Short delay before sending another transmission
    for (size_t i = 0; i < 100; i++) { __NOP(); }
  }
  return 0;
}

void EUSCIB0_IRQHandler(void) {
  if (!(EUSCI_B0->IFG & EUSCI_B_IFG_TXIFG0)) { return; }

  static volatile int packet_idx = 0;
  EUSCI_B0->TXBUF                = PACKET[packet_idx];
  packet_idx                     = (packet_idx + 1) % PACKET_LEN;
}
