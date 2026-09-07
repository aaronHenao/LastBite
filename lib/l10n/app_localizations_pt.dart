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
  String get recetasBuscar => 'Buscar por nome...';

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
}
