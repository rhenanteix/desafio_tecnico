Foi criado um teste de integração que simula um cenário de alta carga:

- 5.000 eventos simultâneos
- Distribuídos entre 50 nodes
- Processados com `Task.async_stream`
- Alta concorrência baseada em schedulers

---