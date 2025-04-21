# Ri-Crypt

Ri-Crypt is a tool for encrypting shell commands using XOR with a random secret key. It generates Rust code to decrypt and execute those commands, then compiles the Rust code and places the binary in the same location as the input file.

## Warning

**Encryption does not support shells that use input readers like `read`.**

```
The following are NOT supported and will fail to run properly:
  read -r name
  hasil_encrypt <your_script.sh> <arg>
Why? Because the script is encoded and executed non-interactively.
```

## Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/RiProG-id/Ri-Crypt
   ```

2. Navigate to the Ri-Crypt directory:

   ```bash
   cd Ri-Crypt
   ```

3. (Optional) If the script is not executable, make it executable:

   ```bash
   chmod +x ricrypt
   ```

4. Make sure all required dependencies are installed:
   - `base64`, `od`, `tr`, `strip`, `rustc`, `cargo`

## Using Ri-Crypt

1. Navigate to the Ri-Crypt directory:

   ```bash
   cd Ri-Crypt
   ```

2. Run the encryption script with your shell file as an argument:

   ```bash
   Usage:    ./ricrypt <your_script.sh>
   Example:  ./ricrypt /sdcard/in/example.sh
   ```

3. After execution, the tool will generate a binary in the same directory as your input file.

## Changelog 3.0

- **Encryption via `$1` Argument**: The encryption process now uses command-line arguments for better flexibility, replacing the previous interactive method.
- **No Setup Script Needed**: All dependencies must be manually installed, simplifying the process by removing the automatic setup script.
- **Multiple Bug Fixes**: Various small fixes and improvements to enhance the stability and performance of the tool.
- **Code Refactoring**: Improved code structure for better maintainability.

## Support and Contact

**Developer Contact:**

- Telegram Channel: [@RiOpSo](https://t.me/RiOpSo)
- Telegram Group: [@RiOpSoDisc](https://t.me/RiOpSoDisc)

**Support Me:**

- Dana: 0831-4095-0951
- Seabank: 901114440459
- PayPal: [PayPal Donation](https://paypal.me/RiProG?country.x=ID&locale.x=id_ID)

Thank you for your support!
