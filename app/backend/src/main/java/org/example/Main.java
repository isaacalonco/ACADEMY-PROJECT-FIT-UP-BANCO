package org.example;

import entidades.Aluno;
import entidades.Instrutor;
import entidades.Plano;
import entidades.Pagamento;
import entidades.Matricula;
import operacoes.AlunoOperacoes;
import operacoes.InstrutorOperacoes;
import operacoes.PlanoOperacoes;
import operacoes.PagamentoOperacoes;
import operacoes.MatriculaOperacoes;

import java.time.LocalDate;
import java.util.List;
import java.util.Scanner;

public class Main {

    static Scanner scanner = new Scanner(System.in);
    static AlunoOperacoes alunoOps = new AlunoOperacoes();
    static InstrutorOperacoes instrutorOps = new InstrutorOperacoes();
    static PlanoOperacoes planoOps = new PlanoOperacoes();
    static PagamentoOperacoes pagamentoOps = new PagamentoOperacoes();
    static MatriculaOperacoes matriculaOps = new MatriculaOperacoes();

    static void clearScreen() {
        try {
            if (System.getProperty("os.name").contains("Windows")) {
                new ProcessBuilder("cmd", "/c", "cls").inheritIO().start().waitFor();
            } else {
                System.out.print("\033[H\033[2J");
                System.out.flush();
            }
        } catch (Exception e) {
            for (int i = 0; i < 50; i++)
                System.out.println();
        }
        System.out.println("\n╔═════════════════════════════════════╗");
        System.out.println("║ Servidor Web: http://localhost:8080 ║");
        System.out.println("╚═════════════════════════════════════╝");
    }

    public static void main(String[] args) {
        banco.Conexao.inicializarBanco();
        ApiServer.start();

        // Modo servidor: sem menu interativo (para testes automatizados)
        boolean modoServidor = false;
        for (String arg : args) {
            if ("--server".equalsIgnoreCase(arg)) {
                modoServidor = true;
                break;
            }
        }
        // Detectar stdin não-interativo (redirecionado / sem console)
        if (!modoServidor && System.console() == null) {
            modoServidor = true;
        }
        if (modoServidor) {
            System.out.println("[INFO] Rodando em modo servidor. API disponível em http://localhost:8080");
            try { Thread.currentThread().join(); } catch (InterruptedException e) { Thread.currentThread().interrupt(); }
            return;
        }

        int opcao = -1;
        while (opcao != 0) {
            clearScreen();
            System.out.println("\n╔════════════════════════════════╗");
            System.out.println("║         SISTEMA FIT UP         ║");
            System.out.println("╠════════════════════════════════╣");
            System.out.println("║ 1 - Alunos                     ║");
            System.out.println("║ 2 - Instrutores                ║");
            System.out.println("║ 3 - Planos                     ║");
            System.out.println("║ 4 - Pagamentos                 ║");
            System.out.println("║ 0 - Sair                       ║");
            System.out.println("╚════════════════════════════════╝");
            System.out.print("Escolha: ");
            opcao = lerInt();

            switch (opcao) {
                case 1:
                    menuAlunos();
                    break;
                case 2:
                    menuInstrutores();
                    break;
                case 3:
                    menuPlanos();
                    break;
                case 4:
                    menuPagamentos();
                    break;
                case 0:
                    System.out.println("Saindo...");
                    break;
                default:
                    System.out.println("Opção inválida!");
            }
        }
        scanner.close();
        System.exit(0);
    }

    // ==================== ALUNOS ====================
    static void menuAlunos() {
        int op = -1;
        while (op != 0) {
            clearScreen();
            System.out.println("\n╔════════════════════════════════╗");
            System.out.println("║             ALUNOS             ║");
            System.out.println("╠════════════════════════════════╣");
            System.out.println("║ 1 - Cadastrar Aluno            ║");
            System.out.println("║ 2 - Listar Alunos              ║");
            System.out.println("║ 3 - Apagar Aluno               ║");
            System.out.println("║ 4 - Vincular/Trocar Plano      ║");
            System.out.println("║ 5 - Editar Aluno               ║");
            System.out.println("║ 0 - Voltar                     ║");
            System.out.println("╚════════════════════════════════╝");
            System.out.print("Escolha: ");
            op = lerInt();

            switch (op) {
                case 1:
                    System.out.print("Nome: ");
                    String nome = scanner.nextLine();
                    System.out.print("CPF: ");
                    String cpf = scanner.nextLine();
                    String cpfFormatado = Validador.formatarCpf(cpf);
                    if (!cpfFormatado.isEmpty() && !cpfFormatado.equals(cpf)) {
                        System.out.println("   -> " + cpfFormatado);
                        cpf = cpfFormatado;
                    }
                    System.out.print("Email: ");
                    String email = scanner.nextLine();
                    System.out.print("Telefone: ");
                    String tel = scanner.nextLine();
                    String telFormatado = Validador.formatarTelefone(tel);
                    if (!telFormatado.isEmpty() && !telFormatado.equals(tel)) {
                        System.out.println("   -> " + telFormatado);
                        tel = telFormatado;
                    }
                    System.out.print("Endereço: ");
                    String end = scanner.nextLine();
                    LocalDate dataNasc = lerData("Data Nascimento (DD/MM/AAAA): ");
                    System.out.print("Peso (kg): ");
                    double peso = lerDouble();
                    System.out.print("Altura (m): ");
                    double altura = lerDouble();

                    Aluno novoAluno = new Aluno(nome, cpf, email, tel, end, dataNasc, peso, altura);
                    Validador.normalizarAluno(novoAluno);
                    String erroAluno = Validador.validarAluno(novoAluno);
                    if (erroAluno != null) {
                        System.out.println("-> Erro de validação: " + erroAluno);
                    } else if (alunoOps.cadastrarAluno(novoAluno)) {
                        System.out.println("-> Aluno cadastrado!");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 2:
                    List<Aluno> alunos = alunoOps.listarAlunos();
                    List<MatriculaOperacoes.MatriculaView> mats = matriculaOps.listarMatriculas();
                    System.out.println("\n--- Lista de Alunos ---");
                    if (alunos.isEmpty()) {
                        System.out.println("Nenhum aluno.");
                    } else {
                        for (Aluno a : alunos) {
                            String planoNome = "Sem plano";
                            for (MatriculaOperacoes.MatriculaView m : mats) {
                                if (m.idAluno == a.getId()) {
                                    planoNome = m.nomePlano;
                                    break;
                                }
                            }
                            System.out.printf("ID: %d | %s | CPF: %s | Email: %s | Plano: %s%n",
                                    a.getId(), a.getNome(), a.getCpf(), a.getEmail(), planoNome);
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 3:
                    List<Aluno> alunosApagar = alunoOps.listarAlunos();
                    if (alunosApagar.isEmpty()) {
                        System.out.println("-> Nenhum aluno cadastrado.");
                    } else {
                        System.out.println("\nAlunos cadastrados:");
                        for (Aluno a : alunosApagar) {
                            System.out.printf("  ID: %d | %s%n", a.getId(), a.getNome());
                        }
                        System.out.println();
                        System.out.print("ID do aluno a apagar: ");
                        int idDel = lerInt();
                        if (alunoOps.deletarAluno(idDel))
                            System.out.println("-> Aluno apagado!");
                        else
                            System.out.println("-> Aluno não encontrado.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 4:
                    List<Aluno> alunosPlano = alunoOps.listarAlunos();
                    if (alunosPlano.isEmpty()) {
                        System.out.println("Nenhum aluno cadastrado! Cadastre um primeiro.");
                        System.out.println("\nPressione Enter para continuar...");
                        scanner.nextLine();
                        break;
                    }
                    List<Plano> planosDisp = planoOps.listarPlanos();
                    if (planosDisp.isEmpty()) {
                        System.out.println("Nenhum plano cadastrado! Cadastre um primeiro.");
                        System.out.println("\nPressione Enter para continuar...");
                        scanner.nextLine();
                        break;
                    }
                    System.out.println("\nAlunos cadastrados:");
                    for (Aluno a : alunosPlano) {
                        System.out.printf("  ID: %d | %s%n", a.getId(), a.getNome());
                    }
                    System.out.println("\nPlanos disponíveis:");
                    for (Plano p : planosDisp) {
                        System.out.printf("  ID: %d | %s | R$ %.2f%n", p.getId(), p.getNome(), p.getValor());
                    }
                    System.out.println();
                    System.out.print("ID do Aluno: ");
                    int idAlPlano = lerInt();
                    System.out.print("ID do Plano: ");
                    int idPlPlano = lerInt();
                    if (matriculaOps.atualizarPlanoDoAluno(idAlPlano, idPlPlano)) {
                        System.out.println("-> Plano vinculado/atualizado com sucesso!");
                    } else {
                        System.out.println("-> Erro ao vincular plano.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 5:
                    List<Aluno> alunosEditar = alunoOps.listarAlunos();
                    if (alunosEditar.isEmpty()) {
                        System.out.println("-> Nenhum aluno cadastrado.");
                    } else {
                        System.out.println("\nAlunos cadastrados:");
                        for (Aluno a : alunosEditar) {
                            System.out.printf("  ID: %d | %s%n", a.getId(), a.getNome());
                        }
                        System.out.println();
                        System.out.print("ID do Aluno a editar: ");
                        int idEditAluno = lerInt();
                        System.out.print("Novo Nome: ");
                        String novoNome = scanner.nextLine();
                        System.out.print("Novo CPF: ");
                        String novoCpf = scanner.nextLine();
                        String editCpfFormatado = Validador.formatarCpf(novoCpf);
                        if (!editCpfFormatado.isEmpty() && !editCpfFormatado.equals(novoCpf)) {
                            System.out.println("   -> " + editCpfFormatado);
                            novoCpf = editCpfFormatado;
                        }
                        System.out.print("Novo Email: ");
                        String novoEmail = scanner.nextLine();
                        System.out.print("Novo Telefone: ");
                        String novoTel = scanner.nextLine();
                        String editTelFormatado = Validador.formatarTelefone(novoTel);
                        if (!editTelFormatado.isEmpty() && !editTelFormatado.equals(novoTel)) {
                            System.out.println("   -> " + editTelFormatado);
                            novoTel = editTelFormatado;
                        }
                        System.out.print("Novo Endereço: ");
                        String novoEnd = scanner.nextLine();
                        LocalDate novaDataNasc = lerData("Nova Data Nascimento (DD/MM/AAAA): ");
                        System.out.print("Novo Peso (kg): ");
                        double novoPeso = lerDouble();
                        System.out.print("Nova Altura (m): ");
                        double novaAltura = lerDouble();

                        Aluno alunoEditado = new Aluno(novoNome, novoCpf, novoEmail, novoTel, novoEnd, novaDataNasc,
                                novoPeso, novaAltura);
                        alunoEditado.setId(idEditAluno);
                        Validador.normalizarAluno(alunoEditado);
                        String erroEditAluno = Validador.validarAluno(alunoEditado);
                        if (erroEditAluno != null) {
                            System.out.println("-> Erro de validação: " + erroEditAluno);
                        } else if (alunoOps.atualizarAluno(alunoEditado)) {
                            System.out.println("-> Aluno atualizado com sucesso!");
                        } else {
                            System.out.println("-> Erro ou Aluno não encontrado.");
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;
            }
        }
    }

    // ==================== INSTRUTORES ====================
    static void menuInstrutores() {
        int op = -1;
        while (op != 0) {
            clearScreen();
            System.out.println("\n╔════════════════════════════════╗");
            System.out.println("║          INSTRUTORES           ║");
            System.out.println("╠════════════════════════════════╣");
            System.out.println("║ 1 - Cadastrar Instrutor        ║");
            System.out.println("║ 2 - Listar Instrutores         ║");
            System.out.println("║ 3 - Apagar Instrutor           ║");
            System.out.println("║ 4 - Editar Instrutor           ║");
            System.out.println("║ 0 - Voltar                     ║");
            System.out.println("╚════════════════════════════════╝");
            System.out.print("Escolha: ");
            op = lerInt();

            switch (op) {
                case 1:
                    System.out.print("Nome: ");
                    String nome = scanner.nextLine();
                    System.out.print("CPF: ");
                    String cpf = scanner.nextLine();
                    String cpfFormatado = Validador.formatarCpf(cpf);
                    if (!cpfFormatado.isEmpty() && !cpfFormatado.equals(cpf)) {
                        System.out.println("   -> " + cpfFormatado);
                        cpf = cpfFormatado;
                    }
                    System.out.print("Email: ");
                    String email = scanner.nextLine();
                    System.out.print("Telefone: ");
                    String tel = scanner.nextLine();
                    String telFormatado = Validador.formatarTelefone(tel);
                    if (!telFormatado.isEmpty() && !telFormatado.equals(tel)) {
                        System.out.println("   -> " + telFormatado);
                        tel = telFormatado;
                    }
                    System.out.print("Especialidade: ");
                    String esp = scanner.nextLine();

                    Instrutor novoInst = new Instrutor(0, nome, cpf, email, tel, esp);
                    Validador.normalizarInstrutor(novoInst);
                    String erroInst = Validador.validarInstrutor(novoInst);
                    if (erroInst != null) {
                        System.out.println("-> Erro de validação: " + erroInst);
                    } else if (instrutorOps.cadastrarInstrutor(novoInst)) {
                        System.out.println("-> Instrutor cadastrado!");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 2:
                    List<Instrutor> instrutores = instrutorOps.listarInstrutores();
                    System.out.println("\n--- Lista de Instrutores ---");
                    if (instrutores.isEmpty()) {
                        System.out.println("Nenhum instrutor.");
                    } else {
                        for (Instrutor i : instrutores) {
                            System.out.printf("ID: %d | %s | CPF: %s | Email: %s | Tel: %s | Esp: %s%n",
                                    i.getIdInstrutor(), i.getNome(), i.getCpf(), i.getEmail(), i.getTelefone(),
                                    i.getEspecialidade());
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 3:
                    List<Instrutor> instsApagar = instrutorOps.listarInstrutores();
                    if (instsApagar.isEmpty()) {
                        System.out.println("-> Nenhum instrutor cadastrado.");
                    } else {
                        System.out.println("\nInstrutores cadastrados:");
                        for (Instrutor i : instsApagar) {
                            System.out.printf("  ID: %d | %s | Especialidade: %s%n", i.getIdInstrutor(), i.getNome(),
                                    i.getEspecialidade());
                        }
                        System.out.println();
                        System.out.print("ID do instrutor a apagar: ");
                        int idDel = lerInt();
                        if (instrutorOps.deletarInstrutor(idDel))
                            System.out.println("-> Instrutor apagado!");
                        else
                            System.out.println("-> Instrutor não encontrado.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 4:
                    List<Instrutor> instsEditar = instrutorOps.listarInstrutores();
                    if (instsEditar.isEmpty()) {
                        System.out.println("-> Nenhum instrutor cadastrado.");
                    } else {
                        System.out.println("\nInstrutores cadastrados:");
                        for (Instrutor i : instsEditar) {
                            System.out.printf("  ID: %d | %s | Especialidade: %s%n", i.getIdInstrutor(), i.getNome(),
                                    i.getEspecialidade());
                        }
                        System.out.println();
                        System.out.print("ID do Instrutor a editar: ");
                        int idEditInst = lerInt();
                        System.out.print("Novo Nome: ");
                        String nNome = scanner.nextLine();
                        System.out.print("Novo CPF: ");
                        String nCpf = scanner.nextLine();
                        String editCpfFormatadoInst = Validador.formatarCpf(nCpf);
                        if (!editCpfFormatadoInst.isEmpty() && !editCpfFormatadoInst.equals(nCpf)) {
                            System.out.println("   -> " + editCpfFormatadoInst);
                            nCpf = editCpfFormatadoInst;
                        }
                        System.out.print("Novo Email: ");
                        String nEmail = scanner.nextLine();
                        System.out.print("Novo Telefone: ");
                        String nTel = scanner.nextLine();
                        String editTelFormatadoInst = Validador.formatarTelefone(nTel);
                        if (!editTelFormatadoInst.isEmpty() && !editTelFormatadoInst.equals(nTel)) {
                            System.out.println("   -> " + editTelFormatadoInst);
                            nTel = editTelFormatadoInst;
                        }
                        System.out.print("Nova Especialidade: ");
                        String nEsp = scanner.nextLine();

                        Instrutor instrutorEditado = new Instrutor(idEditInst, nNome, nCpf, nEmail, nTel, nEsp);
                        Validador.normalizarInstrutor(instrutorEditado);
                        String erroEditInst = Validador.validarInstrutor(instrutorEditado);
                        if (erroEditInst != null) {
                            System.out.println("-> Erro de validação: " + erroEditInst);
                        } else if (instrutorOps.atualizarInstrutor(instrutorEditado)) {
                            System.out.println("-> Instrutor atualizado com sucesso!");
                        } else {
                            System.out.println("-> Erro ou Instrutor não encontrado.");
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;
            }
        }
    }

    // ==================== PLANOS ====================
    static void menuPlanos() {
        int op = -1;
        while (op != 0) {
            clearScreen();
            System.out.println("\n╔════════════════════════════════╗");
            System.out.println("║             PLANOS             ║");
            System.out.println("╠════════════════════════════════╣");
            System.out.println("║ 1 - Cadastrar Plano            ║");
            System.out.println("║ 2 - Listar Planos              ║");
            System.out.println("║ 3 - Apagar Plano               ║");
            System.out.println("║ 4 - Editar Plano               ║");
            System.out.println("║ 0 - Voltar                     ║");
            System.out.println("╚════════════════════════════════╝");
            System.out.print("Escolha: ");
            op = lerInt();

            switch (op) {
                case 1:
                    System.out.print("Nome do Plano: ");
                    String nome = scanner.nextLine();
                    System.out.print("Valor Mensal (R$): ");
                    double valor = lerDouble();

                    Plano novoPlano = new Plano(0, nome, valor);
                    String erroPlano = Validador.validarPlano(novoPlano);
                    if (erroPlano != null) {
                        System.out.println("-> Erro de validação: " + erroPlano);
                    } else if (planoOps.cadastrarPlano(novoPlano)) {
                        System.out.println("-> Plano cadastrado!");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 2:
                    List<Plano> planos = planoOps.listarPlanos();
                    System.out.println("\n--- Lista de Planos ---");
                    if (planos.isEmpty()) {
                        System.out.println("Nenhum plano.");
                    } else {
                        for (Plano p : planos) {
                            System.out.printf("ID: %d | %s | R$ %.2f%n", p.getId(), p.getNome(), p.getValor());
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 3:
                    List<Plano> planosApagar = planoOps.listarPlanos();
                    if (planosApagar.isEmpty()) {
                        System.out.println("-> Nenhum plano cadastrado.");
                    } else {
                        System.out.println("\nPlanos cadastrados:");
                        for (Plano p : planosApagar) {
                            System.out.printf("  ID: %d | %s | R$ %.2f%n", p.getId(), p.getNome(), p.getValor());
                        }
                        System.out.println();
                        System.out.print("ID do plano a apagar: ");
                        int idDel = lerInt();
                        if (planoOps.deletarPlano(idDel))
                            System.out.println("-> Plano apagado!");
                        else
                            System.out.println("-> Plano não encontrado.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 4:
                    List<Plano> planosEditar = planoOps.listarPlanos();
                    if (planosEditar.isEmpty()) {
                        System.out.println("-> Nenhum plano cadastrado.");
                    } else {
                        System.out.println("\nPlanos cadastrados:");
                        for (Plano p : planosEditar) {
                            System.out.printf("  ID: %d | %s | R$ %.2f%n", p.getId(), p.getNome(), p.getValor());
                        }
                        System.out.println();
                        System.out.print("ID do Plano a editar: ");
                        int idEditPlano = lerInt();
                        System.out.print("Novo Nome do Plano: ");
                        String nNomePlano = scanner.nextLine();
                        System.out.print("Novo Valor Mensal (R$): ");
                        double nValor = lerDouble();

                        Plano planoEditado = new Plano(idEditPlano, nNomePlano, nValor);
                        String erroEditPlano = Validador.validarPlano(planoEditado);
                        if (erroEditPlano != null) {
                            System.out.println("-> Erro de validação: " + erroEditPlano);
                        } else if (planoOps.atualizarPlano(planoEditado)) {
                            System.out.println("-> Plano atualizado com sucesso!");
                        } else {
                            System.out.println("-> Erro ou Plano não encontrado.");
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;
            }
        }
    }

    // ==================== PAGAMENTOS ====================
    static void menuPagamentos() {
        int op = -1;
        while (op != 0) {
            clearScreen();
            System.out.println("\n╔════════════════════════════════╗");
            System.out.println("║          PAGAMENTOS            ║");
            System.out.println("╠════════════════════════════════╣");
            System.out.println("║ 1 - Registrar Pagamento        ║");
            System.out.println("║ 2 - Listar Pagamentos          ║");
            System.out.println("║ 3 - Apagar Pagamento           ║");
            System.out.println("║ 4 - Atualizar Status Pagamento ║");
            System.out.println("║ 0 - Voltar                     ║");
            System.out.println("╚════════════════════════════════╝");
            System.out.print("Escolha: ");
            op = lerInt();

            switch (op) {
                case 1:
                    List<Aluno> alunos = alunoOps.listarAlunos();
                    if (alunos.isEmpty()) {
                        System.out.println("-> Nenhum aluno cadastrado para registrar pagamento.");
                        System.out.println("\nPressione Enter para continuar...");
                        scanner.nextLine();
                        break;
                    }
                    List<MatriculaOperacoes.MatriculaView> matsTotal = matriculaOps.listarMatriculas();
                    System.out.println("\nAlunos cadastrados:");
                    for (Aluno a : alunos) {
                        String planoNome = "Sem plano";
                        for (MatriculaOperacoes.MatriculaView m : matsTotal) {
                            if (m.idAluno == a.getId()) {
                                planoNome = m.nomePlano;
                                break;
                            }
                        }
                        System.out.printf("  ID: %d | %s | Plano: %s%n", a.getId(), a.getNome(), planoNome);
                    }
                    System.out.println();
                    System.out.print("ID do Aluno: ");
                    int idAluno = lerInt();

                    double valorPag = 0;
                    List<MatriculaOperacoes.MatriculaView> matsAluno = matriculaOps.listarMatriculas();
                    String nomePlanoAluno = null;
                    for (MatriculaOperacoes.MatriculaView mv : matsAluno) {
                        if (mv.idAluno == idAluno) {
                            nomePlanoAluno = mv.nomePlano;
                            break;
                        }
                    }
                    if (nomePlanoAluno != null) {
                        List<Plano> planosDisp2 = planoOps.listarPlanos();
                        for (Plano pl : planosDisp2) {
                            if (pl.getNome().equals(nomePlanoAluno)) {
                                valorPag = pl.getValor();
                                break;
                            }
                        }
                        System.out.printf("-> Plano detectado: %s | Valor: R$ %.2f%n", nomePlanoAluno, valorPag);
                    } else {
                        System.out.println("-> Aluno sem plano vinculado. Digite o valor manualmente:");
                        System.out.print("Valor (R$): ");
                        valorPag = lerDouble();
                    }

                    System.out.print("Status (Pago/Pendente/Atrasado): ");
                    String status = scanner.nextLine();

                    Pagamento novoPag = new Pagamento(0, idAluno, valorPag, status);
                    String erroPag = Validador.validarPagamento(novoPag);
                    if (erroPag != null) {
                        System.out.println("-> Erro de validação: " + erroPag);
                    } else if (pagamentoOps.cadastrarPagamento(novoPag)) {
                        System.out.println("-> Pagamento registrado!");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 2:
                    List<PagamentoOperacoes.PagamentoView> pags = pagamentoOps.listarPagamentos();
                    System.out.println("\n--- Lista de Pagamentos ---");
                    if (pags.isEmpty()) {
                        System.out.println("Nenhum pagamento.");
                    } else {
                        for (PagamentoOperacoes.PagamentoView p : pags) {
                            System.out.printf("ID: %d | Aluno: %s | R$ %.2f | Status: %s%n",
                                    p.idPagamento, p.nomeAluno, p.valor, p.status);
                        }
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 3:
                    List<PagamentoOperacoes.PagamentoView> pagsApagar = pagamentoOps.listarPagamentos();
                    if (pagsApagar.isEmpty()) {
                        System.out.println("-> Nenhum pagamento registrado.");
                    } else {
                        System.out.println("\nPagamentos registrados:");
                        for (PagamentoOperacoes.PagamentoView p : pagsApagar) {
                            System.out.printf("  ID: %d | Aluno: %s | R$ %.2f | Status: %s%n",
                                    p.idPagamento, p.nomeAluno, p.valor, p.status);
                        }
                        System.out.println();
                        System.out.print("ID do pagamento a apagar: ");
                        int idDel = lerInt();
                        if (pagamentoOps.deletarPagamento(idDel))
                            System.out.println("-> Pagamento apagado!");
                        else
                            System.out.println("-> Pagamento não encontrado.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;

                case 4:
                    List<PagamentoOperacoes.PagamentoView> pagsEditar = pagamentoOps.listarPagamentos();
                    if (pagsEditar.isEmpty()) {
                        System.out.println("-> Nenhum pagamento registrado.");
                    } else {
                        System.out.println("\nPagamentos registrados:");
                        for (PagamentoOperacoes.PagamentoView p : pagsEditar) {
                            System.out.printf("  ID: %d | Aluno: %s | R$ %.2f | Status: %s%n",
                                    p.idPagamento, p.nomeAluno, p.valor, p.status);
                        }
                        System.out.println();
                        System.out.print("ID do Pagamento a atualizar: ");
                        int idEditPag = lerInt();
                        System.out.print("Novo Status (Pago/Pendente/Atrasado): ");
                        String novoStatus = scanner.nextLine();

                        if (pagamentoOps.atualizarStatusPagamento(idEditPag, novoStatus))
                            System.out.println("-> Status updated com sucesso!");
                                                                                  
                        else
                            System.out.println(
                                    "-> Erro: certifique-se de que o ID é válido e o status é 'Pago', 'Pendente' ou 'Atrasado'.");
                    }
                    System.out.println("\nPressione Enter para continuar...");
                    scanner.nextLine();
                    break;
            }
        }
    }

    // ==================== HELPERS ====================
    static int lerInt() {
        try {
            return Integer.parseInt(scanner.nextLine());
        } catch (Exception e) {
            return -1;
        }
    }

    static double lerDouble() {
        try {
            return Double.parseDouble(scanner.nextLine().replace(",", "."));
        } catch (Exception e) {
            return 0;
        }
    }

    static LocalDate lerData(String prompt) {
        System.out.print(prompt);
        String str = scanner.nextLine();
        LocalDate data = Validador.parseDataBr(str);
        if (data == null) {
            if (!str.isBlank()) {
                System.out.println("Data inválida, usando data atual.");
            }
            data = LocalDate.now();
        } else {
            System.out.println("   -> " + Validador.formatarDataBr(data));
        }
        return data;
    }
}