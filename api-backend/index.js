const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());

const pool = mysql.createPool({
  host: '10.108.34.95',
  user: 'root',
  password: 'root',
  database: 'db_prod',
  port: 3306
});

// Testa a conexão ao iniciar o servidor
pool.getConnection((err, connection) => {
  if (err) {
    console.error('Erro ao conectar ao banco:', err.message);
  } else {
    console.log('Conexão com o banco estabelecida com sucesso!');
    connection.release();
  }
});

// Endpoint para dashboard
app.get('/dashboard', (req, res) => {
  console.log(`[${new Date().toLocaleString()}] Requisição recebida para /dashboard`);
  pool.query(
    `SELECT COUNT(*) as total FROM tb_prod WHERE DATE(data_hora) = CURDATE()`,
    (err, totalResult) => {
      if (err) {
        console.error('Erro na query totalPiecesToday:', err.message);
        return res.status(500).json({ error: err.message });
      }
      pool.query(
        `SELECT HOUR(data_hora) as hour, COUNT(*) as count FROM tb_prod WHERE DATE(data_hora) = CURDATE() GROUP BY HOUR(data_hora) ORDER BY HOUR(data_hora) ASC LIMIT 24`,
        (err, hoursResult) => {
          if (err) {
            console.error('Erro na query productionByHour:', err.message);
            return res.status(500).json({ error: err.message });
          }
          pool.query(
            `SELECT m.material as destination, COUNT(*) as count FROM tb_prod p JOIN tb_material m ON p.id_material = m.id_material WHERE DATE(p.data_hora) = CURDATE() GROUP BY m.material`,
            (err, destResult) => {
              if (err) {
                console.error('Erro na query productionByDestination:', err.message);
                return res.status(500).json({ error: err.message });
              }
              pool.query(
                `SELECT p.data_hora, 'inserção' as operation, '' as status, p.tipo_peca, m.material as destination FROM tb_prod p JOIN tb_material m ON p.id_material = m.id_material ORDER BY p.data_hora DESC LIMIT 10`,
                (err, actResult) => {
                  if (err) {
                    console.error('Erro na query recentActivities:', err.message);
                    return res.status(500).json({ error: err.message });
                  }
                  console.log(`[${new Date().toLocaleString()}] Dashboard entregue com sucesso!`);
                  res.json({
                    totalPiecesToday: totalResult[0].total,
                    productionByHour: hoursResult,
                    productionByDestination: destResult,
                    recentActivities: actResult,
                    successRate: 100.0,
                    activeAlerts: 0
                  });
                }
              );
            }
          );
        }
      );
    }
  );
});

app.listen(3000, () => {
  console.log('API rodando na porta 3000');
});
