// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class L10nPt extends L10n {
  L10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appNombre => 'LastBite';

  @override
  String get navDespensa => 'Despensa';

  @override
  String get navAgregar => 'Adicionar';

  @override
  String get navRecetas => 'Receitas';

  @override
  String get navAlertas => 'Alertas';

  @override
  String get accionVolver => 'Voltar';

  @override
  String get accionReintentar => 'Tentar de novo';

  @override
  String get accionCancelar => 'Cancelar';

  @override
  String get accionAgregarProducto => 'Adicionar produto';

  @override
  String get accionLimpiarBusqueda => 'Limpar busca';

  @override
  String get accionDetalleTecnico => 'Detalhe técnico';

  @override
  String get cuentaMenu => 'Menu da conta';

  @override
  String get cuentaMia => 'Minha conta';

  @override
  String get cuentaPerfil => 'Perfil e lista de compras';

  @override
  String get cuentaCompartida => 'Despensa compartilhada';

  @override
  String get cuentaConsultaRapida => 'Consulta rápida';

  @override
  String get cuentaAccesibilidad => 'Acessibilidade';

  @override
  String get cuentaCerrarSesion => 'Sair';

  @override
  String get despensaTitulo => 'Minha Despensa';

  @override
  String get despensaProductos => 'Produtos';

  @override
  String get despensaSalvados => 'Salvos';

  @override
  String get despensaPorVencer => 'A vencer';

  @override
  String get despensaProximosAVencer => 'PRÓXIMOS DO VENCIMENTO';

  @override
  String get despensaEnBuenEstado => 'EM BOM ESTADO';

  @override
  String get despensaVaciaTitulo => 'Sua despensa está vazia';

  @override
  String get despensaVaciaDescripcion =>
      'Adicione o que você tem em casa e avisamos antes de vencer.';

  @override
  String get despensaErrorCarga => 'Não conseguimos carregar sua despensa.';

  @override
  String get estadoVencido => 'Vencido!';

  @override
  String get estadoHoy => 'Hoje';

  @override
  String get estadoManana => 'Amanhã';

  @override
  String estadoDias(int dias) {
    return '${dias}d';
  }

  @override
  String lectorProducto(
    String nombre,
    String cantidad,
    String categoria,
    String estado,
  ) {
    return '$nombre, $cantidad, $categoria, $estado';
  }

  @override
  String get lectorVenceHoy => 'vence hoje';

  @override
  String get lectorVenceManana => 'vence amanhã';

  @override
  String lectorVenceEnDias(int dias) {
    return 'vence em $dias dias';
  }

  @override
  String lectorVencidoHace(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'vencido há $dias dias',
      one: 'vencido há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get ajustesTitulo => 'Acessibilidade';

  @override
  String get ajustesDescripcion =>
      'Ajuste o app ao jeito que você precisa usar. Tudo fica salvo na sua conta, então acompanha você do celular à web.';

  @override
  String get ajustesTamanoTexto => 'TAMANHO DO TEXTO';

  @override
  String get ajustesTamanoTextoAyuda =>
      'O app inteiro cresce com este ajuste, não só esta tela.';

  @override
  String get ajustesEscalaNormal => 'Normal';

  @override
  String get ajustesEscalaGrande => 'Grande';

  @override
  String get ajustesEscalaMasGrande => 'Maior';

  @override
  String get ajustesEscalaMaxima => 'Máximo';

  @override
  String get ajustesContraste => 'CONTRASTE';

  @override
  String get ajustesContrasteAyuda =>
      'Aumenta o contraste ao máximo e reforça as bordas. Ajuda com baixa visão e sob sol forte.';

  @override
  String get ajustesAltoContraste => 'Alto contraste';

  @override
  String get ajustesMovimiento => 'MOVIMENTO';

  @override
  String get ajustesMovimientoAyuda =>
      'Desliga as transições. Útil se o movimento na tela te deixa tonto ou te distrai.';

  @override
  String get ajustesReducirMovimiento => 'Reduzir movimento';

  @override
  String get ajustesApariencia => 'APARÊNCIA';

  @override
  String get ajustesAparienciaAyuda =>
      'Automático segue o ajuste do seu dispositivo.';

  @override
  String get ajustesTemaAutomatico => 'Automático';

  @override
  String get ajustesTemaClaro => 'Claro';

  @override
  String get ajustesTemaOscuro => 'Escuro';

  @override
  String get ajustesIdioma => 'IDIOMA';

  @override
  String get ajustesIdiomaAyuda =>
      'Automático usa o idioma do seu dispositivo.';

  @override
  String get ajustesIdiomaAutomatico => 'Automático';

  @override
  String get ajustesLectorTitulo => 'Leitor de tela';

  @override
  String get ajustesLectorAyuda =>
      'O app está preparado para TalkBack e VoiceOver: cada produto é anunciado com nome, quantidade e quanto tempo resta. Você ativa nos ajustes do seu dispositivo, não aqui.';

  @override
  String alertaDescartar(String producto) {
    return 'Descartar alerta de $producto';
  }

  @override
  String get alertasVaciasTitulo => 'Tudo sob controle';

  @override
  String get alertasVaciasDescripcion =>
      'Nenhum produto da sua despensa está perto de vencer. Avisamos assim que algum estiver.';

  @override
  String get alertasErrorCarga => 'Não conseguimos carregar seus alertas.';

  @override
  String get compartidaTitulo => 'Despensa compartilhada';

  @override
  String get compartidaIntro =>
      'Compartilhe uma só despensa com sua família: os produtos, os alertas e as receitas são os mesmos para todos.';

  @override
  String get compartidaCrear => 'Criar despensa';

  @override
  String get compartidaCrearAyuda =>
      'Gera um código para sua família entrar na sua despensa.';

  @override
  String get compartidaUnirme => 'Entrar com código';

  @override
  String get compartidaUnirmeAyuda =>
      'Você já tem um código de 6 caracteres da sua família.';

  @override
  String get compartidaNotaUnaSola =>
      'Você só pode estar em uma despensa por vez: a sua ou uma compartilhada.';

  @override
  String get compartidaEresAdmin => 'Você é o administrador desta despensa.';

  @override
  String compartidaAdministradaPor(String nombre) {
    return 'Administrada por $nombre.';
  }

  @override
  String get compartidaOtroMiembro => 'outro membro';

  @override
  String get compartidaCodigoRotulo => 'CÓDIGO DE CONVITE';

  @override
  String get compartidaCopiar => 'Copiar';

  @override
  String get compartidaCodigoCopiado => 'Código copiado';

  @override
  String compartidaMiembros(int cantidad) {
    return 'MEMBROS ($cantidad)';
  }

  @override
  String get compartidaSalir => 'Sair da despensa';

  @override
  String get compartidaSalirCeder => 'Sair e passar a administração';

  @override
  String get compartidaEliminar => 'Excluir despensa';

  @override
  String get compartidaCrearTitulo => 'Criar despensa da família';

  @override
  String get compartidaCrearDescripcion =>
      'Dê um nome. Depois você compartilha o código com sua família.';

  @override
  String get compartidaNombreDefecto => 'Despensa da família';

  @override
  String get compartidaNombrePlaceholder => 'Nome da despensa';

  @override
  String get compartidaAccionCrear => 'Criar';

  @override
  String get compartidaUnirmeTitulo => 'Entrar em uma despensa';

  @override
  String get compartidaUnirmeDescripcion =>
      'Digite o código de 6 caracteres que te passaram.';

  @override
  String get compartidaAccionUnirme => 'Entrar';

  @override
  String get compartidaSinCodigo => 'Não existe uma despensa com esse código.';

  @override
  String get compartidaMigrarTitulo => 'Migrar seus produtos';

  @override
  String compartidaMigrarDescripcion(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other:
          'Você tem $cantidad produtos na sua despensa pessoal. Quer movê-los para a compartilhada? Se não, eles ficam onde estão.',
      one:
          'Você tem 1 produto na sua despensa pessoal. Quer movê-lo para a compartilhada? Se não, ele fica onde está.',
    );
    return '$_temp0';
  }

  @override
  String get compartidaMigrar => 'Migrar';

  @override
  String get compartidaNoMigrar => 'Não migrar';

  @override
  String get compartidaEliminarDescripcion =>
      'Todos voltam para a sua despensa pessoal e os produtos compartilhados passam para a sua. Isso não pode ser desfeito.';

  @override
  String get compartidaEliminarAccion => 'Excluir';

  @override
  String get compartidaExpulsarTitulo => 'Remover membro';

  @override
  String compartidaExpulsarDescripcion(String nombre) {
    return '$nombre volta para a sua despensa pessoal e deixa de ver esta.';
  }

  @override
  String get compartidaSalirDescripcion =>
      'Você volta para a sua despensa pessoal. Os produtos que você adicionou ficam na compartilhada.';

  @override
  String get compartidaSalirAccion => 'Sair';

  @override
  String get compartidaNuevoAdminTitulo => 'Quem administra a despensa?';

  @override
  String get compartidaNuevoAdminDescripcion =>
      'Quem você escolher poderá adicionar e remover membros, e excluir a despensa.';

  @override
  String get compartidaContinuar => 'Continuar';

  @override
  String compartidaCederDescripcion(String nombre) {
    return '$nombre passa a ser o administrador e você volta para a sua despensa pessoal. Os produtos que você adicionou ficam na compartilhada.';
  }

  @override
  String get compartidaCreada => 'Despensa criada';

  @override
  String get compartidaTeUniste => 'Você entrou na despensa';

  @override
  String get compartidaSaliste => 'Você saiu da despensa';

  @override
  String compartidaSalisteConAdmin(String nombre) {
    return 'Você saiu da despensa. Agora $nombre administra.';
  }

  @override
  String get compartidaEliminada => 'Despensa excluída';

  @override
  String compartidaMiembroSalio(String nombre) {
    return '$nombre saiu da despensa';
  }

  @override
  String get perfilUsuario => 'Usuário';

  @override
  String perfilSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad alimentos salvos',
      one: '1 alimento salvo',
    );
    return '$_temp0';
  }

  @override
  String get perfilNutricional => 'Perfil nutricional';

  @override
  String get perfilNutricionalAyuda =>
      'Adapta as receitas às suas preferências';

  @override
  String get perfilListaCompras => 'LISTA DE COMPRAS';

  @override
  String get perfilComprados => 'COMPRADOS';

  @override
  String get perfilLimpiarComprados => 'Limpar comprados';

  @override
  String get perfilLimpiar => 'Limpar';

  @override
  String get perfilLimpiarPregunta =>
      'Remover todos os produtos marcados como comprados?';

  @override
  String get perfilListaVaciaTitulo => 'Sua lista de compras está vazia';

  @override
  String get perfilListaVaciaDescripcion =>
      'Os produtos que você consumir ou remover vão aparecer aqui.';

  @override
  String perfilMarcarComprado(String nombre) {
    return 'Marcar $nombre como comprado';
  }

  @override
  String perfilConsumido(String fecha) {
    return 'Consumido: $fecha';
  }

  @override
  String perfilVencido(String fecha) {
    return 'Venceu: $fecha';
  }

  @override
  String get perfilErrorLista =>
      'Não conseguimos carregar sua lista de compras.';

  @override
  String get recetasRotulo => 'MOTOR DE RECEITAS';

  @override
  String get recetasTitulo => 'Resíduo Zero';

  @override
  String get recetasBuscar =>
      'Digite um ingrediente ou prato e toque em buscar';

  @override
  String get recetasGenerando => 'A IA está preparando mais receitas…';

  @override
  String get recetasSugeridas => 'RECEITAS SUGERIDAS';

  @override
  String get recetasMenorTiempo => 'Menor tempo';

  @override
  String get recetasOrdenarMenorTiempo => 'Ordenar por menor tempo';

  @override
  String get recetasPriorizando => 'Priorizando ingredientes urgentes';

  @override
  String get recetasSinProductos => 'Não há produtos na sua despensa';

  @override
  String get recetasSinUrgentes => 'Não há produtos urgentes na sua despensa';

  @override
  String get recetasErrorCarga => 'Não foi possível carregar receitas';

  @override
  String get recetasSinResultados => 'Sem resultados';

  @override
  String recetasSinResultadosDescripcion(String busqueda) {
    return 'Nenhuma receita corresponde a \"$busqueda\".';
  }

  @override
  String get recetasSinSugerenciasTitulo => 'Ainda não há sugestões';

  @override
  String get recetasSinSugerenciasDescripcion =>
      'Adicione produtos à sua despensa e sugerimos receitas que os aproveitem.';

  @override
  String get recetasBuscarDeNuevo => 'Buscar de novo';

  @override
  String get recetasCocinarTitulo => 'O que você usou por completo?';

  @override
  String get recetasCocinarDescripcion =>
      'O que você marcar sai da sua despensa e conta para os alimentos salvos. Desmarque o que ainda sobrar.';

  @override
  String get recetasSinCoincidencias =>
      'Nenhum dos seus produtos combina com esta receita.';

  @override
  String get recetasConfirmar => 'Confirmar';

  @override
  String recetasSalvados(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad produtos salvos. Bom apetite!',
      one: '1 produto salvo. Bom apetite!',
    );
    return '$_temp0';
  }

  @override
  String get agregarRotulo => 'ADICIONAR ALIMENTO';

  @override
  String get agregarTitulo => 'Entrada Híbrida';

  @override
  String get agregarEscanear => 'Escanear';

  @override
  String get agregarManual => 'Manual';

  @override
  String get agregarApuntaCodigo => 'Aponte para o código de barras';

  @override
  String get agregarTocaCamara => 'Toque para abrir a câmera';

  @override
  String get agregarBuscando => 'Procurando o produto…';

  @override
  String agregarUltimoCodigo(String codigo) {
    return 'Último código: $codigo';
  }

  @override
  String get agregarNoEncontrado =>
      'Produto não encontrado. Adicione manualmente.';

  @override
  String get agregarSinConexion =>
      'Sem conexão. Não conseguimos consultar o código.';

  @override
  String agregarGuardado(String nombre) {
    return '$nombre adicionado à despensa.';
  }

  @override
  String get agregarNombre => 'Nome';

  @override
  String get agregarNombreProducto => 'Nome do produto';

  @override
  String get agregarNombreEjemplo => 'Ex: Iogurte grego';

  @override
  String get agregarCategoria => 'Selecione uma categoria';

  @override
  String get agregarElegirCategoria => 'Escolha a categoria';

  @override
  String get agregarCantidad => 'Quantidade';

  @override
  String get agregarUnidad => 'Unidade';

  @override
  String get agregarFecha => 'Data de vencimento';

  @override
  String get agregarElegirFecha => 'Selecione uma data';

  @override
  String get agregarFechaRecomendada =>
      'Esta é a data de validade recomendada para este produto';

  @override
  String get agregarGuardar => 'Salvar produto';

  @override
  String get agregarFaltanCampos => 'Preencha nome e data.';

  @override
  String get agregarNombreVacio => 'O nome não pode ficar vazio.';

  @override
  String get agregarConfirmar => 'CONFIRMAR PRODUTO';

  @override
  String get agregarAgregarADespensa => 'Adicionar à minha despensa';

  @override
  String get accionDeshacer => 'Desfazer';

  @override
  String get cuentaAyuda => 'Ajuda';

  @override
  String get accesoListaCompras => 'Lista de compras';

  @override
  String get accesoCompartida => 'Compartilhada';

  @override
  String get accesoBuscar => 'Buscar';

  @override
  String get ayudaTitulo => 'Ajuda';

  @override
  String get ayudaDescripcion =>
      'Como usar o LastBite e respostas às dúvidas mais comuns.';

  @override
  String get ayudaAbrir => 'Abrir ajuda';

  @override
  String get ayudaPrimerosPasos => 'PRIMEIROS PASSOS';

  @override
  String get ayudaPaso1 =>
      'Adicione o que você tem em casa: escaneie o código de barras ou digite.';

  @override
  String get ayudaPaso2 =>
      'Confira sua despensa: os produtos que vencem primeiro ficam no topo.';

  @override
  String get ayudaPaso3 =>
      'Cozinhe com as receitas sugeridas e marque o que usou como consumido para somar alimentos salvos.';

  @override
  String get ayudaPreguntas => 'PERGUNTAS FREQUENTES';

  @override
  String get ayudaSeccionDespensa => 'Despensa';

  @override
  String get ayudaSeccionAgregar => 'Adicionar produtos';

  @override
  String get ayudaSeccionRecetas => 'Receitas';

  @override
  String get ayudaSeccionAlertas => 'Alertas';

  @override
  String get ayudaSeccionCompartir =>
      'Despensa compartilhada e lista de compras';

  @override
  String get ayudaSeccionCuenta => 'Busca, conta e ajustes';

  @override
  String get ayudaDespensaP1 => 'Como marco que usei um produto?';

  @override
  String get ayudaDespensaR1 =>
      'Toque nele na despensa e escolha «Marcar como consumido». Soma aos seus alimentos salvos e à economia do mês. Se errar, toque em «Desfazer» no aviso que aparece embaixo.';

  @override
  String get ayudaDespensaP2 => 'O que significam os dias de cada produto?';

  @override
  String get ayudaDespensaR2 =>
      'São os dias que faltam para vencer. «Próximos do vencimento» reúne os que vencem em 3 dias ou menos; os vencidos ficam em vermelho.';

  @override
  String get ayudaDespensaP3 => 'Como a economia é calculada?';

  @override
  String get ayudaDespensaR3 =>
      'É uma estimativa: o que você consumiu antes de vencer, multiplicado por um preço médio da categoria.';

  @override
  String get ayudaAgregarP1 => 'E se o código de barras não aparecer?';

  @override
  String get ayudaAgregarR1 =>
      'O LastBite muda para o cadastro manual. Digite o nome, escolha a categoria e salve.';

  @override
  String get ayudaAgregarP2 => 'Quem escolhe a data de vencimento?';

  @override
  String get ayudaAgregarR2 =>
      'O app sugere uma conforme a categoria do produto. Mude antes de salvar se a embalagem disser outra.';

  @override
  String get ayudaRecetasP1 => 'O que significa a porcentagem de cada receita?';

  @override
  String get ayudaRecetasR1 =>
      'É a parte dos ingredientes que você já tem. Os básicos (sal, pimenta, óleo e água) contam como disponíveis. No detalhe, cada ingrediente diz «Você tem», «Básico» ou «Falta».';

  @override
  String get ayudaRecetasP2 =>
      'Por que as receitas não mudam quando mudo a despensa?';

  @override
  String get ayudaRecetasR2 =>
      'Para você não perder a que estava vendo. Quando sua despensa muda, aparece um aviso com o botão «Atualizar receitas».';

  @override
  String get ayudaRecetasP3 => 'Por que demoram para aparecer?';

  @override
  String get ayudaRecetasR3 =>
      'Uma IA cria as receitas a partir da sua despensa e pode levar alguns segundos. A primeira aparece assim que fica pronta.';

  @override
  String get ayudaRecetasP4 => 'O que acontece ao tocar «Já cozinhei»?';

  @override
  String get ayudaRecetasR4 =>
      'Você escolhe quais produtos acabaram e eles são marcados como consumidos. Dá para desfazer pelo aviso.';

  @override
  String get ayudaAlertasP1 => 'Quando aparece um alerta?';

  @override
  String get ayudaAlertasR1 =>
      'Quando um produto está para vencer ou já venceu. Os alertas ficam salvos até você apagá-los.';

  @override
  String get ayudaAlertasP2 => 'Não recebo as notificações';

  @override
  String get ayudaAlertasR2 =>
      'Verifique se o LastBite tem permissão de notificações nos ajustes do seu celular.';

  @override
  String get ayudaCompartirP1 =>
      'Como compartilho a despensa com minha família?';

  @override
  String get ayudaCompartirR1 =>
      'Toque em «Compartilhada» na despensa e crie uma despensa. Passe o código para quem quiser adicionar: essa pessoa toca em «Entrar com código» e digita.';

  @override
  String get ayudaCompartirP2 => 'Onde fica a lista de compras?';

  @override
  String get ayudaCompartirR2 =>
      'Em «Lista de compras», no topo da despensa. Ao consumir ou excluir um produto, o LastBite oferece adicioná-lo.';

  @override
  String get ayudaCuentaP1 => 'Como busco um produto?';

  @override
  String get ayudaCuentaR1 =>
      'Toque em «Buscar» na despensa. Não precisa escrever o nome exato: a ordem das palavras, os acentos e um erro de digitação não importam.';

  @override
  String get ayudaCuentaP2 =>
      'Como mudo o tamanho do texto, o tema ou o idioma?';

  @override
  String get ayudaCuentaR2 =>
      'No menu da sua conta, «Acessibilidade». Lá você também pode restaurar tudo ao padrão.';

  @override
  String despensaSalvado(String nombre) {
    return 'Você salvou $nombre.';
  }

  @override
  String despensaSalvadoYEnLista(String nombre) {
    return 'Você salvou $nombre. Ficou na sua lista de compras.';
  }

  @override
  String despensaEliminado(String nombre) {
    return 'Você tirou $nombre da despensa.';
  }

  @override
  String despensaEliminadoYEnLista(String nombre) {
    return 'Você tirou $nombre da despensa. Ficou na sua lista de compras.';
  }

  @override
  String get recetasBuscando =>
      'Buscando receitas com o que você tem. Pode levar alguns segundos.';

  @override
  String get recetasDespensaCambio =>
      'Sua despensa mudou. Estas receitas ficam até você decidir atualizá-las.';

  @override
  String get recetasActualizar => 'Atualizar receitas';

  @override
  String recetasFaltan(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'Faltam $cantidad',
      one: 'Falta 1',
    );
    return '$_temp0';
  }

  @override
  String recetasTienesDeTotal(int disponibles, int total) {
    return 'Você tem $disponibles de $total ingredientes';
  }

  @override
  String get recetasIngredienteTienes => 'Você tem';

  @override
  String get recetasIngredienteBasico => 'Básico';

  @override
  String get recetasIngredienteFalta => 'Falta';

  @override
  String get recetasBasicosNota =>
      '«Básico» é sal, pimenta, óleo ou água: supomos que você tem em casa.';

  @override
  String get recetasIngredientes => 'INGREDIENTES';

  @override
  String get recetasPreparacion => 'PREPARO';

  @override
  String agregarGuardadoVence(String nombre, int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$nombre está na sua despensa. Vence em $dias dias.',
      one: '$nombre está na sua despensa. Vence amanhã.',
      zero: '$nombre está na sua despensa. Vence hoje.',
    );
    return '$_temp0';
  }

  @override
  String get ajustesRestablecer => 'Restaurar ajustes';

  @override
  String get ajustesRestablecerAyuda =>
      'Volta o tamanho do texto, o contraste, o movimento, o tema e o idioma ao padrão. Seus produtos, listas e alertas não são alterados.';

  @override
  String get ajustesRestablecerPregunta => 'Restaurar os ajustes?';

  @override
  String get ajustesRestablecerAccion => 'Restaurar';

  @override
  String get ajustesRestablecidos => 'Os ajustes voltaram ao padrão.';

  @override
  String consultaSinResultados(String busqueda) {
    return 'Não encontramos «$busqueda»';
  }

  @override
  String get consultaSinResultadosDescripcion =>
      'Tente outra palavra. Não precisa escrever o nome exato nem usar acentos.';

  @override
  String get despensaConsumir => 'Marcar como consumido';

  @override
  String get despensaConsumirAyuda => 'Soma aos seus alimentos salvos';

  @override
  String get despensaEliminar => 'Excluir';

  @override
  String get despensaEliminarAyuda => 'Não soma aos alimentos salvos';

  @override
  String get despensaListaPregunta => 'Adicionar à lista de compras?';

  @override
  String despensaListaDescripcion(String nombre) {
    return 'Adicionar $nombre à sua lista para a próxima compra.';
  }

  @override
  String get despensaListaNo => 'Não, obrigado';

  @override
  String get despensaListaSi => 'Adicionar';

  @override
  String get recetasYaLaCocine => 'Já cozinhei';

  @override
  String get categoriaVerdura => 'Verdura';

  @override
  String get categoriaFruta => 'Fruta';

  @override
  String get categoriaHierba => 'Ervas';

  @override
  String get categoriaCarne => 'Carne';

  @override
  String get categoriaPollo => 'Frango';

  @override
  String get categoriaPescado => 'Peixe';

  @override
  String get categoriaHuevo => 'Ovos';

  @override
  String get categoriaLeche => 'Leite';

  @override
  String get categoriaYogur => 'Iogurte';

  @override
  String get categoriaQueso => 'Queijo';

  @override
  String get categoriaMantequilla => 'Manteiga';

  @override
  String get categoriaPan => 'Pão';

  @override
  String get categoriaEmbutido => 'Frios';

  @override
  String get categoriaJugo => 'Suco';

  @override
  String get categoriaGrano => 'Grãos';

  @override
  String get categoriaConserva => 'Conserva';

  @override
  String get categoriaCereal => 'Cereal';

  @override
  String get categoriaOtro => 'Outro';

  @override
  String get unidadUnidad => 'unidade';

  @override
  String get unidadCucharada => 'c. sopa';

  @override
  String get unidadTaza => 'xícara';

  @override
  String cantidadUnidades(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'unidades',
      one: 'unidade',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadTazas(String numero, num cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: 'xícaras',
      one: 'xícara',
    );
    return '$numero $_temp0';
  }

  @override
  String cantidadCucharadas(String numero) {
    return '$numero c. sopa';
  }

  @override
  String get temaAutomaticoAccion => 'Tema: automático. Toque para mudar.';

  @override
  String get temaClaroAccion => 'Tema: claro. Toque para mudar.';

  @override
  String get temaOscuroAccion => 'Tema: escuro. Toque para mudar.';

  @override
  String get cuentaPerfilAyuda => 'Ver perfil e lista de compras';

  @override
  String get cuentaCompartidaAyuda => 'Crie uma ou entre com um código';

  @override
  String get cuentaConsultaRapidaAyuda => 'Buscar produtos da sua despensa';

  @override
  String get cuentaAccesibilidadAyuda =>
      'Tamanho do texto, contraste e movimento';

  @override
  String despensaAhorroMes(DateTime mes) {
    final intl.DateFormat mesDateFormat = intl.DateFormat.MMMM(localeName);
    final String mesString = mesDateFormat.format(mes);

    return 'Economia estimada de $mesString';
  }

  @override
  String get despensaAhorroVacio =>
      'Consuma um produto antes de vencer para começar a somar';

  @override
  String get despensaAhorroNota => 'Estimativa com preços médios por categoria';

  @override
  String get agregarCantidadEjemplo => 'Ex.: 1';

  @override
  String get alertasRotulo => 'ALERTAS';

  @override
  String get alertasTitulo => 'Validade e receitas';

  @override
  String get alertasNota => 'Os alertas ficam até você decidir apagá-los.';

  @override
  String get alertasBorrarTodo => 'Apagar tudo';

  @override
  String get alertasBorrarPregunta => 'Apagar todos os alertas';

  @override
  String get alertasBorrarDescripcion =>
      'Isto apaga os alertas atuais. Os novos são gerados quando necessário.';

  @override
  String get alertasEliminadas => 'Alertas apagados';

  @override
  String alertaDescartada(String producto) {
    return 'Alerta de $producto descartado';
  }

  @override
  String get alertaDescartarCorto => 'Descartar';

  @override
  String get alertaDescartarTooltip => 'Descartar alerta';

  @override
  String get alertaRecetaSugerida => 'RECEITA SUGERIDA';

  @override
  String get alertaTituloAviso5 => 'Primeiro aviso';

  @override
  String get alertaTituloAviso3 => 'Aviso crítico';

  @override
  String get alertaTituloAviso1 => 'Último dia';

  @override
  String get alertaTituloVencido => 'Produto vencido';

  @override
  String alertaMensajeAviso5(String producto) {
    return 'Seu $producto vence em 5 dias. Fique atento.';
  }

  @override
  String alertaMensajeAviso3(String producto) {
    return 'Seu $producto vence em 3 dias. Sugerimos uma receita.';
  }

  @override
  String alertaMensajeAviso1(String producto) {
    return 'Seu $producto vence amanhã. Aproveite hoje.';
  }

  @override
  String alertaMensajeVencido(String producto) {
    return 'Seu $producto já venceu. Tire-o da despensa.';
  }

  @override
  String get notifCanal => 'Alertas de vencimento';

  @override
  String get notifCanalDescripcion =>
      'Notificações de produtos perto do vencimento';

  @override
  String notifVenceManana(String producto) {
    return '$producto vence amanhã';
  }

  @override
  String get notifVenceMananaConReceta =>
      'Aproveite hoje: toque para ver uma receita sugerida.';

  @override
  String get notifVenceMananaSinReceta =>
      'É seu último dia para usá-lo. Não desperdice!';

  @override
  String notifVenceEn3(String producto) {
    return '$producto vence em 3 dias';
  }

  @override
  String get notifVenceEn3Cuerpo => 'Planeje uma receita antes que seja tarde.';

  @override
  String notifVencido(String producto) {
    return '$producto já venceu';
  }

  @override
  String get notifVencidoCuerpo => 'Tire-o da sua despensa.';

  @override
  String get authBienvenido => 'Bem-vindo ao';

  @override
  String get authCorreo => 'E-mail';

  @override
  String get authCorreoEjemplo => 'voce@email.com';

  @override
  String get authContrasena => 'Senha';

  @override
  String get authConfirmarContrasena => 'Confirmar senha';

  @override
  String get authIniciarSesion => 'Entrar';

  @override
  String get authOContinua => 'ou continue com';

  @override
  String get authContinuarGoogle => 'Continuar com o Google';

  @override
  String get authSinCuentaPregunta => 'Não tem conta? ';

  @override
  String get authRegistrate => 'Cadastre-se';

  @override
  String get authCreaCuenta => 'Crie sua conta';

  @override
  String get authCreaCuentaAyuda => 'Comece a salvar seus alimentos';

  @override
  String get authNombre => 'Nome';

  @override
  String get authNombreEjemplo => 'Seu nome';

  @override
  String get authCrearCuenta => 'Criar conta';

  @override
  String get authCompletaCampos => 'Preencha todos os campos.';

  @override
  String get authContrasenasNoCoinciden => 'As senhas não coincidem.';

  @override
  String get authContrasenaCorta => 'A senha deve ter pelo menos 6 caracteres.';

  @override
  String get authCredencialesIncorrectas => 'E-mail ou senha incorretos.';

  @override
  String get authCorreoRegistrado => 'Este e-mail já está cadastrado.';

  @override
  String get authCorreoInvalido => 'O e-mail não é válido.';

  @override
  String get authSinCuenta => 'Não existe uma conta com este e-mail.';

  @override
  String get authContrasenaIncorrecta => 'Senha incorreta.';

  @override
  String get authDemasiadosIntentos => 'Muitas tentativas. Aguarde um momento.';

  @override
  String get authSinConexion => 'Sem conexão com a internet.';

  @override
  String get authVentanaBloqueada =>
      'O navegador bloqueou a janela do Google. Permita pop-ups.';

  @override
  String authErrorDesconocido(String codigo) {
    return 'Não foi possível concluir o acesso. Código: $codigo';
  }

  @override
  String get compartidaMiembroSinNombre => 'Membro';

  @override
  String compartidaTu(String nombre) {
    return '$nombre (você)';
  }

  @override
  String get compartidaAdmin => 'ADMIN';

  @override
  String get compartidaEliminarMiembro => 'Remover membro';

  @override
  String compartidaErrorLargoCodigo(int largo) {
    return 'O código deve ter $largo caracteres.';
  }

  @override
  String get compartidaErrorCodigoInexistente =>
      'Não existe uma despensa com esse código.';

  @override
  String get compartidaErrorNoExiste => 'Esta despensa não existe mais.';

  @override
  String get compartidaErrorUnicoMiembro =>
      'Você é o único membro. Exclua a despensa em vez de sair.';

  @override
  String get compartidaErrorElegirAdmin =>
      'Escolha quem fica como administrador antes de sair.';

  @override
  String get compartidaErrorAdminInvalido =>
      'O novo administrador deve ser outro membro da despensa.';

  @override
  String get compartidaErrorSoloAdminMiembros =>
      'Só o administrador pode remover membros.';

  @override
  String get compartidaErrorAdminNoSeElimina =>
      'O administrador não pode remover a si mesmo.';

  @override
  String get compartidaErrorSoloAdminEliminar =>
      'Só o administrador pode excluir a despensa.';

  @override
  String get compartidaErrorYaPerteneces =>
      'Você já participa de uma despensa compartilhada. Saia dela primeiro.';

  @override
  String get compartidaErrorSinCodigo =>
      'Não foi possível gerar um código. Tente de novo.';

  @override
  String get compartidaErrorSinSesion => 'Você precisa entrar.';

  @override
  String get compartidaErrorDesconocido => 'Algo deu errado. Tente de novo.';

  @override
  String get escanerPermisoTitulo => 'Permissão de câmera necessária';

  @override
  String get escanerPermisoDescripcion =>
      'Precisamos de acesso à câmera para escanear o código de barras.';

  @override
  String get escanerEntendido => 'Entendi';

  @override
  String get escanerTitulo => 'Escanear produto';

  @override
  String get escanerApagarFlash => 'Desligar flash';

  @override
  String get escanerEncenderFlash => 'Ligar flash';

  @override
  String get escanerCambiarCamara => 'Trocar câmera';

  @override
  String get escanerPermisoDenegado => 'Permissão de câmera negada';

  @override
  String get escanerNoInicia => 'Não foi possível iniciar a câmera';

  @override
  String get escanerAlinea => 'Alinhe o código de barras dentro da moldura';

  @override
  String get nutricionalRotulo => 'PERFIL NUTRICIONAL';

  @override
  String get nutricionalTitulo => 'Preferências de receitas';

  @override
  String get nutricionalTipoUsuario => 'Tipo de usuário';

  @override
  String get nutricionalSinPreferencia => 'Sem preferência';

  @override
  String get nutricionalDeportista => 'Atleta';

  @override
  String get nutricionalPlan => 'Plano nutricional';

  @override
  String get nutricionalObjetivo => 'Objetivo nutricional';

  @override
  String get nutricionalSinObjetivo => 'Sem objetivo específico';

  @override
  String get nutricionalPerderPeso => 'Perder peso';

  @override
  String get nutricionalMantenerPeso => 'Manter o peso';

  @override
  String get nutricionalGanarPeso => 'Ganhar peso';

  @override
  String get nutricionalAlimentacion => 'Tipo de alimentação';

  @override
  String get nutricionalOmnivora => 'Onívora';

  @override
  String get nutricionalVegetariana => 'Vegetariana';

  @override
  String get nutricionalVegana => 'Vegana';

  @override
  String get nutricionalOtra => 'Outra';

  @override
  String get nutricionalRestricciones => 'Restrições alimentares';

  @override
  String get nutricionalRestriccionesEjemplo => 'Ex.: porco, frutos do mar';

  @override
  String get nutricionalAlergias => 'Alergias ou intolerâncias';

  @override
  String get nutricionalAlergiasEjemplo => 'Ex.: amendoim, glúten';

  @override
  String get nutricionalGuardar => 'Salvar perfil';

  @override
  String get nutricionalErrorGuardar =>
      'Não foi possível salvar o perfil. Verifique sua conexão e tente de novo.';

  @override
  String get nutricionalGuardado => 'Perfil nutricional salvo';

  @override
  String get consultaTitulo => 'Consulta rápida';

  @override
  String get consultaBuscar => 'Buscar produto';

  @override
  String get consultaErrorCarga => 'Não foi possível carregar seus produtos.';

  @override
  String get consultaVacia =>
      'Sua despensa está vazia. Adicione produtos para consultá-los aqui.';

  @override
  String get consultaCantidad => 'Quantidade';

  @override
  String get consultaFechaCaducidad => 'Data de vencimento';

  @override
  String get consultaEstado => 'Estado';

  @override
  String get consultaEstadoVencido => 'Vencido';

  @override
  String get consultaEstadoPorVencer => 'Perto do vencimento';

  @override
  String get consultaEstadoVigente => 'Em bom estado';

  @override
  String get consultaHistorialTitulo => 'Buscas recentes';

  @override
  String get consultaHistorialLimpiar => 'Limpar histórico';

  @override
  String get recetasErrorFaltaClave =>
      'Falta a chave da IA. Rode o app com --dart-define-from-file=env.json.';

  @override
  String get recetasErrorRespuestaVacia =>
      'A IA respondeu vazio. Tente de novo.';

  @override
  String get recetasErrorTiempo =>
      'A IA demorou demais para responder. Tente de novo.';

  @override
  String get recetasErrorSinConexion =>
      'Sem conexão com o serviço de receitas. Verifique sua internet.';

  @override
  String get recetasErrorClave => 'A chave da IA não é válida ou expirou.';

  @override
  String get recetasErrorCreditos => 'Os créditos do serviço de IA acabaram.';

  @override
  String get recetasErrorModeloInexistente =>
      'O modelo de IA configurado não existe.';

  @override
  String get recetasErrorModeloRetirado =>
      'A NVIDIA retirou o modelo de IA configurado.';

  @override
  String get recetasErrorDemasiadas =>
      'Muitas consultas à IA. Aguarde um momento.';

  @override
  String get recetasErrorServicio =>
      'O serviço de IA não está disponível agora.';

  @override
  String get recetasErrorSinRecetas =>
      'A IA não devolveu receitas válidas. Tente de novo.';

  @override
  String get recetasErrorFormato =>
      'A IA respondeu num formato inesperado. Tente de novo.';

  @override
  String get recetasErrorIncompleta =>
      'A resposta da IA chegou incompleta. Tente de novo.';

  @override
  String get recetasErrorDetalle =>
      'O detalhe desta receita não está mais disponível. Atualize as sugestões para gerar uma nova.';

  @override
  String get recetasErrorSinIngredientes =>
      'Não há ingredientes válidos para buscar receitas.';

  @override
  String get recetasErrorDesconocido => 'Não foi possível gerar receitas.';

  @override
  String get recetasErrorDetalleCarga =>
      'Não foi possível carregar o preparo. Verifique sua conexão.';

  @override
  String get recetasOrdenDesayuno => 'É cedo: primeiro as de café da manhã';

  @override
  String get recetasOrdenPrincipal => 'Primeiro os pratos principais';

  @override
  String get recetasOrdenSemana => 'É dia de semana: primeiro as mais rápidas';

  @override
  String get recetasOrdenFinde =>
      'É fim de semana: dá tempo para algo mais elaborado';

  @override
  String recetasMatch(int porcentaje) {
    return '$porcentaje% compatível';
  }

  @override
  String recetasLikes(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad curtidas',
      one: '1 curtida',
    );
    return '$_temp0';
  }

  @override
  String get accionCerrar => 'Fechar';
}
