Optei por classes estáticas ou inline source devido ao comportamento de tree-shaking do Tailwind v4, evitando perda de estilos dinâmicos em runtime.
Para evitar gargalos eu basicamente agrupei as atualizações que faço por intervalo

Segue um exmplo :
> Process.send_after(self(), :broadcast_batch, 100)

Nas mudanças no terceiro passo o que eu validei para não ter erros é que :

- A liveView só vai escutar o que está precisando