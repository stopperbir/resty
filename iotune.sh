#!/bin/bash
# Linux native format (LF only)
# NVMe RAID5 (md0) + Nginx VOD / HLS I/O tuning
# System: 4x NVMe (14T) -> md0 mounted on /home

echo ""
echo "=== 🚀 Disk ve I/O Optimizasyon Başlıyor (NVMe RAID5) ==="

########################################
# RAID DEVICE (md0)
########################################
if [ -b /dev/md0 ]; then
  echo "→ RAID5 device: /dev/md0"

  # Read-ahead (2MB ideal for VOD/HLS)
  blockdev --setra 4096 /dev/md0

  # Stripe cache (read-heavy workload)
  if [ -w /sys/block/md0/md/stripe_cache_size ]; then
    echo 32768 > /sys/block/md0/md/stripe_cache_size
  fi
fi

########################################
# NVMe DISKS (under md0)
########################################
for d in nvme0n1 nvme1n1 nvme2n1 nvme3n1; do
  if [ -b /dev/$d ]; then
    echo "→ NVMe disk: /dev/$d"

    # NVMe: scheduler = none
    if [ -w /sys/block/$d/queue/scheduler ]; then
      echo none > /sys/block/$d/queue/scheduler 2>/dev/null || true
    fi

    # Moderate readahead (md handles main buffering)
    blockdev --setra 128 /dev/$d

    # Queue depth (NVMe benefits from higher queue)
    echo 1024 > /sys/block/$d/queue/nr_requests 2>/dev/null || true
  fi
done

########################################
# OS DISK (sda) - be gentle
########################################
if [ -b /dev/sda ]; then
  echo "→ OS disk: /dev/sda"

  blockdev --setra 1024 /dev/sda

  if [ -w /sys/block/sda/queue/scheduler ]; then
    echo mq-deadline > /sys/block/sda/queue/scheduler 2>/dev/null || true
  fi

  echo 256 > /sys/block/sda/queue/nr_requests 2>/dev/null || true
fi

########################################
# LOOP DEVICES (snap etc.)
########################################
for d in /sys/block/loop*; do
  dev=$(basename "$d")
  if [ -b /dev/$dev ]; then
    echo "→ Loop device: /dev/$dev"
    blockdev --setra 8 /dev/$dev 2>/dev/null || true
  fi
done

########################################
# RAID SYNC SPEED (safe values)
########################################
for f in /sys/block/md0/md/sync_speed_max /sys/block/md0/md/sync_speed_min; do
  [ -w "$f" ] && echo 500000 > "$f"
done

########################################
# SUMMARY
########################################
echo ""
echo "==== Block Device Report ===="
blockdev --report | grep -E 'md0|nvme|sda'
echo ""
echo "==== md0 Stripe Cache Size ===="
cat /sys/block/md0/md/stripe_cache_size 2>/dev/null || echo "md0 stripe cache not found"
echo ""
echo "✅ I/O tuning başarıyla uygulandı!"
