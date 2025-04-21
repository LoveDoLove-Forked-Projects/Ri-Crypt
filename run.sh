#!/bin/bash
commands=("base64" "od" "tr" "strip" "rustc" "cargo")
missing=""
for cmd in "${commands[@]}"; do
	if ! command -v "$cmd" &>/dev/null; then
		missing+="$cmd "
	fi
done
if [ -n "$missing" ]; then
	echo "Missing: $missing"
	echo "Installing..."
	apt update
	[[ ! $(command -v od) ]] && apt install -y bsdmainutils
	[[ ! $(command -v tr) ]] && apt install -y coreutils
	[[ ! $(command -v strip) ]] && apt install -y binutils
	[[ ! $(command -v rustc) || ! $(command -v cargo) ]] && apt install -y rust
	[[ ! $(command -v base64) ]] && apt install -y coreutils
	for cmd in "${commands[@]}"; do
		command -v "$cmd" &>/dev/null && echo "$cmd installed" || echo "$cmd failed"
	done
fi
clear
echo ""
echo "Ri-Crypt 3.0 by RiProG-id"
echo ""
echo "WARNING: This encryption does NOT support interactive input or arguments!"
echo ""
echo "The following are NOT supported and will fail to run properly:"
echo "  read -r name"
echo "  encryptedresult <$1> <$2>"
echo ""
echo "Reason: The script is encoded and executed in a non-interactive shell."
echo ""
echo "Usage:    ./ricrypt <your_script.sh>"
echo "Example:  ./ricrypt /sdcard/in/example.sh"
echo ""
if [ ! -f "$input" ]; then
	echo "Error: File '$input' not found"
	exit 1
fi
interpreter=$(awk 'NR==1 && /^#!/ {gsub(".*/","",$1); print $1}' "$input")
[[ "$interpreter" != "bash" && "$interpreter" != "sh" ]] && echo "Unsupported interpreter" && exit 1
basename=$(basename -- "$input")
basename_no_ext="${basename%.*}"
dirname=$(dirname -- "$input")
basefile="$dirname/$basename_no_ext.base"
xorfile="$dirname/$basename_no_ext.xor"
rustfile="$dirname/$basename_no_ext.rs"
binfile="$dirname/$basename_no_ext"
echo "Encoding to Base64..."
printf "eval 'echo \"" >"$basefile"
base64 -w 0 "$input" >>"$basefile"
printf "\" | base64 -d | $interpreter'" >>"$basefile"
command=$(cat "$basefile")
length=${#command}
echo "Generating key..."
key=$(od -An -N1 -tx1 /dev/urandom | tr -d ' ')
echo "Key: 0x$key"
encrypted=""
for ((i = 0; i < length; i++)); do
	char="${command:$i:1}"
	ascii=$(printf "%d" "'$char")
	enc=$(printf "%02x" $((ascii ^ 0x$key)))
	encrypted+="$enc "
done
echo "Writing XOR data..."
{
	echo "let key: u8 = 0x$key;"
	printf "let encrypted_command: [u8; $length] = ["
	printf "0x%s, " $encrypted | sed 's/, $//'
	echo "];"
} >"$xorfile"
echo "Generating Rust..."
{
	echo 'use std::process::Command;'
	echo 'fn decrypt_command(encrypted: &[u8], key: u8) -> String {'
	echo '    encrypted.iter().map(|&b| (b ^ key) as char).collect()'
	echo '}'
	echo 'fn main() {'
	cat "$xorfile"
	echo '    let decrypted = decrypt_command(&encrypted_command, key);'
	echo '    let output = Command::new("sh").arg("-c").arg(decrypted).output().unwrap();'
	echo '    if !output.stdout.is_empty() { println!("{}", String::from_utf8_lossy(&output.stdout)); }'
	echo '    if !output.stderr.is_empty() { eprintln!("{}", String::from_utf8_lossy(&output.stderr)); }'
	echo '}'
} >"$rustfile"

rustfmt "$rustfile"
rustc -C opt-level=3 "$rustfile" -o "$binfile"
strip "$binfile"
rm "$basefile" "$xorfile" "$rustfile"
echo "Done: $binfile"
