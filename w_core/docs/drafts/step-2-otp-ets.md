O estado em memória (ETS) utiliza átomos para performance,
enquanto a persistência usa strings para compatibilidade com o banco.

Essa conversão é feita na camada de write-behind