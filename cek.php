<?php
session_start();
require_once "config.php";

$conn = pg_connect("host=$db_host port=$db_port dbname=$db_name user=$db_user password=$db_pass");
if (!$conn) {
  die("Koneksi PostgreSQL gagal: " . htmlspecialchars(pg_last_error()));
}

/* =========================
   DETAIL PER ORANG (opsional)
   akses: cek.php?id=3
   ========================= */
$detail = null;
if (isset($_GET['id'])) {
  $id = (int)$_GET['id'];

  $qDetail = "SELECT id, survey_date, survey_time, gender, education, jobs, services,
                    q1,q2,q3,q4,q5,q6,q7,q8,q9,
                    nama_pasien, alamat, nomor_hp, keluhan
             FROM kuesioner
             WHERE id = $1
             LIMIT 1";

  $resDetail = pg_query_params($conn, $qDetail, [$id]);
  if ($resDetail && pg_num_rows($resDetail) > 0) {
    $detail = pg_fetch_assoc($resDetail);
  }
}

/* =========================
   LIST DATA TERBARU
   =========================
   NOTE: created_at aku hapus agar tidak error kalau kolomnya tidak ada
*/
$sql = "SELECT id, survey_date, survey_time, gender, education, jobs, services,
               q1,q2,q3,q4,q5,q6,q7,q8,q9,
               nama_pasien, alamat, nomor_hp, keluhan
        FROM kuesioner
        ORDER BY id ASC
        LIMIT 200";

$result = pg_query($conn, $sql);
if (!$result) {
  die("Query gagal: " . htmlspecialchars(pg_last_error($conn)));
}

$rows = pg_fetch_all($result);
?>
<!DOCTYPE html>
<html lang="id">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cek Hasil Kuesioner - RS Ekahusada</title>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <div class="container">

    <div class="header">
      <div class="header-logo">
        <div class="logo-container">
          <img src="images/logo.png" alt="Logo RS Ekahusada" class="logo-icon">
        </div>
        <div class="header-text">
          <h1>RS EKAHUSADA</h1>
          <p>CEK HASIL KUESIONER</p>
        </div>
      </div>
    </div>

    <div class="form-container">
      <h2 class="section-title">Data Masuk (Terbaru)</h2>

      <div style="margin-bottom:15px; display:flex; gap:10px; flex-wrap:wrap; align-items:center;">
        <a class="back-button" href="index.php" style="text-decoration:none; padding:12px 18px; border-radius:8px; font-weight:600; display:inline-block;">
          ⬅️ Kembali ke Form
        </a>

        <?php if ($detail): ?>
          <a class="btn-small outline" href="cek.php" style="text-decoration:none;">
            Tutup Detail
          </a>
        <?php endif; ?>
      </div>

      <!-- ====== PANEL DETAIL (muncul kalau ada ?id=...) ====== -->
      <?php if ($detail): ?>
        <?php
          $scoresD = [
            (int)$detail['q1'], (int)$detail['q2'], (int)$detail['q3'], (int)$detail['q4'], (int)$detail['q5'],
            (int)$detail['q6'], (int)$detail['q7'], (int)$detail['q8'], (int)$detail['q9']
          ];
          $totalD = array_sum($scoresD);
          $keluhan = trim((string)($detail['keluhan'] ?? ''));
        ?>
        <div class="detail-card">
          <div class="detail-header">
            <div>
              <div class="detail-title">Detail Responden</div>
              <div class="detail-sub">
                ID #<?php echo htmlspecialchars($detail['id']); ?> •
                <?php echo htmlspecialchars($detail['survey_date']); ?> (<?php echo htmlspecialchars($detail['survey_time']); ?>)
              </div>
            </div>
            <a class="btn-small outline" href="cek.php" style="text-decoration:none;">Tutup</a>
          </div>

          <div class="detail-grid">
            <div class="detail-item">
              <div class="label">Nama</div>
              <div class="value"><?php echo htmlspecialchars($detail['nama_pasien']); ?></div>
            </div>

            <div class="detail-item">
              <div class="label">Nomor HP</div>
              <div class="value"><?php echo htmlspecialchars($detail['nomor_hp']); ?></div>
            </div>

            <div class="detail-item">
              <div class="label">Alamat</div>
              <div class="value"><?php echo htmlspecialchars($detail['alamat']); ?></div>
            </div>

            <div class="detail-item">
              <div class="label">Gender / Pendidikan</div>
              <div class="value"><?php echo htmlspecialchars($detail['gender']); ?> / <?php echo htmlspecialchars($detail['education']); ?></div>
            </div>

            <div class="detail-item">
              <div class="label">Pekerjaan</div>
              <div class="value"><?php echo htmlspecialchars($detail['jobs']); ?></div>
            </div>

            <div class="detail-item">
              <div class="label">Layanan</div>
              <div class="value"><?php echo htmlspecialchars($detail['services']); ?></div>
            </div>
          </div>

          <div class="detail-scores">
            <div class="label">Skor Q1–Q9</div>
            <div class="value mono"><?php echo htmlspecialchars(implode(' - ', $scoresD)); ?></div>
            <span class="badge">Total: <?php echo $totalD; ?></span>
          </div>

          <div class="detail-keluhan">
            <div class="label">Keluhan / Saran</div>
            <div class="value">
              <?php echo $keluhan !== '' ? nl2br(htmlspecialchars($keluhan)) : '<em>Tidak ada keluhan.</em>'; ?>
            </div>
          </div>
        </div>
      <?php endif; ?>

      <?php if (!$rows): ?>
        <div class="scale-note">
          Belum ada data yang masuk.
        </div>
      <?php else: ?>
        <div class="table-wrap">
          <table class="table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Tanggal</th>
                <th>Jam</th>
                <th>Nama</th>
                <th>Gender</th>
                <th>Pendidikan</th>
                <th>Pekerjaan</th>
                <th>Layanan</th>
                <th class="col-score">Skor (Q1–Q9)</th>
                <th>Aksi</th>
              </tr>
            </thead>
            <tbody>
              <?php foreach ($rows as $r): ?>
                <?php
                $scores = [
                  (int)$r['q1'], (int)$r['q2'], (int)$r['q3'], (int)$r['q4'], (int)$r['q5'],
                  (int)$r['q6'], (int)$r['q7'], (int)$r['q8'], (int)$r['q9']
                ];
                $total = array_sum($scores);
                ?>
                <tr>
                  <td><?php echo htmlspecialchars($r['id']); ?></td>
                  <td><?php echo htmlspecialchars($r['survey_date']); ?></td>
                  <td><?php echo htmlspecialchars($r['survey_time']); ?></td>
                  <td><?php echo htmlspecialchars($r['nama_pasien']); ?></td>
                  <td><?php echo htmlspecialchars($r['gender']); ?></td>
                  <td><?php echo htmlspecialchars($r['education']); ?></td>
                  <td><?php echo htmlspecialchars($r['jobs']); ?></td>
                  <td><?php echo htmlspecialchars($r['services']); ?></td>

                  <td class="col-score">
                    <div class="score-wrap">
                      <span class="score-values"><?php echo htmlspecialchars(implode('-', $scores)); ?></span>
                      <span class="badge"><?php echo "Total: $total"; ?></span>
                    </div>
                  </td>

                  <td>
                    <a class="btn-small" href="cek.php?id=<?php echo urlencode($r['id']); ?>" style="text-decoration:none;">
                      Detail
                    </a>
                  </td>
                </tr>
              <?php endforeach; ?>
            </tbody>
          </table>
        </div>
      <?php endif; ?>

      <div class="scale-note" style="margin-top:20px;">
        Klik tombol <b>Detail</b> untuk melihat keluhan/saran dan data lengkap responden.
      </div>
    </div>

    <footer class="footer">
      <div class="footer-content">
        <h2>TERIMA KASIH</h2>
        <p>RS Ekahusada - Melayani Dengan Sepenuh Hati</p>
      </div>
    </footer>

  </div>
</body>

</html>
