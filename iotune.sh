#!/bin/bash
# Linux native format (LF only)
# RAID + HDD + NVMe + Loop + Nginx VOD optimizasyon scripti

echo ""
echo "=== 🚀 Disk ve I/O Optimizasyon Başlıyor ==="

# RAID5 arrays (mdadm)
for d in md0 md1 md2 md127; do
  if [ -b /dev/$d ]; then
    echo "→ RAID device: /dev/$d"
    blockdev --setra 2048 /dev/$d
    if [ -w /sys/block/$d/queue/scheduler ]; then
      echo bfq > /sys/block/$d/queue/scheduler 2>/dev/null || true
    fi
  fi
done

# HDD (sata diskler)
for d in sda sdb sdc sdd; do
  if [ -b /dev/$d ]; then
    echo "→ HDD: /dev/$d"
    blockdev --setra 256 /dev/$d
    echo deadline > /sys/block/$d/queue/scheduler 2>/dev/null || true
    echo 128 > /sys/block/$d/queue/nr_requests 2>/dev/null || true
  fi
done

# NVMe diskler
for d in nvme0n1 nvme1n1; do
  if [ -b /dev/$d ]; then
    echo "→ NVMe: /dev/$d"
    blockdev --setra 64 /dev/$d
    echo none > /sys/block/$d/queue/scheduler 2>/dev/null || true
    echo 512 > /sys/block/$d/queue/nr_requests 2>/dev/null || true
  fi
done

# Loop cihazları
for d in loop0 loop1 loop2; do
  if [ -b /dev/$d ]; then
    echo "→ Loop: /dev/$d"
    blockdev --setra 8 /dev/$d
  fi
done

# RAID stripe cache tuning
if [ -w /sys/block/md127/md/stripe_cache_size ]; then
  echo 8192 > /sys/block/md127/md/stripe_cache_size
fi

# RAID write-intent cache
for f in /sys/block/md*/md/sync_speed_*; do
  [ -w "$f" ] && echo 500000 > "$f"
done

# Özet rapor
echo ""
echo "==== Block Device Report ===="
blockdev --report
echo ""
echo "==== Stripe Cache Size (md127) ===="
cat /sys/block/md127/md/stripe_cache_size 2>/dev/null || echo "md127 bulunamadı"
echo ""
echo "Ayarlar başarıyla uygulandı! ⚡"
