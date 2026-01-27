<?php
$db_host = "localhost";
$db_port = "5432";
$db_name = "pengaduanlayanan";
$db_user = "postgres";
$db_pass = "1234";

$conn = pg_connect("host=$db_host port=$db_port dbname=$db_name user=$db_user password=$db_pass");
if (!$conn) die("Koneksi gagal");

$q = pg_query($conn, "SELECT id, created_at, nama_pasien, survey_date, survey_time, q1,q2,q3,q4,q5,q6,q7,q8,q9
                      FROM kuesioner ORDER BY id DESC LIMIT 50");
if (!$q) die(pg_last_error($conn));
?>
<!doctype html>
<html>
<head><meta charset="utf-8"><title>Cek Kuesioner</title></head>
<body>
<h2>Data Kuesioner (50 terbaru)</h2>
<table border="1" cellpadding="8" cellspacing="0">
<tr>
  <th>ID</th><th>Created</th><th>Nama</th><th>Tanggal</th><th>Jam</th>
  <th>q1</th><th>q2</th><th>q3</th><th>q4</th><th>q5</th><th>q6</th><th>q7</th><th>q8</th><th>q9</th>
</tr>
<?php while ($row = pg_fetch_assoc($q)): ?>
<tr>
  <td><?= htmlspecialchars($row['id']) ?></td>
  <td><?= htmlspecialchars($row['created_at']) ?></td>
  <td><?= htmlspecialchars($row['nama_pasien']) ?></td>
  <td><?= htmlspecialchars($row['survey_date']) ?></td>
  <td><?= htmlspecialchars($row['survey_time']) ?></td>
  <td><?= htmlspecialchars($row['q1']) ?></td>
  <td><?= htmlspecialchars($row['q2']) ?></td>
  <td><?= htmlspecialchars($row['q3']) ?></td>
  <td><?= htmlspecialchars($row['q4']) ?></td>
  <td><?= htmlspecialchars($row['q5']) ?></td>
  <td><?= htmlspecialchars($row['q6']) ?></td>
  <td><?= htmlspecialchars($row['q7']) ?></td>
  <td><?= htmlspecialchars($row['q8']) ?></td>
  <td><?= htmlspecialchars($row['q9']) ?></td>
</tr>
<?php endwhile; ?>
</table>
</body>
</html>
