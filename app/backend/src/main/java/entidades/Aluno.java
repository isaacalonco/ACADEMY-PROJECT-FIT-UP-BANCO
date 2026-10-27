package entidades;

import java.time.LocalDate;
import java.time.Period;

public class Aluno extends Pessoa {

    private int id;
    private String endereco;
    private LocalDate dataNascimento;
    private double peso;
    private double altura;
    private LocalDate dataCadastro;
    private boolean ativo;

    public Aluno() {
        super();
    }

    public Aluno(String nome, String cpf, String email,
                 String telefone, String endereco,
                 LocalDate dataNascimento,
                 double peso, double altura) {

        super(nome, cpf, email, telefone);
        this.endereco = endereco;
        this.dataNascimento = dataNascimento;
        this.peso = peso;
        this.altura = altura;
        this.dataCadastro = LocalDate.now();
        this.ativo = true;
    }

    @Override
    public String getDescricao() {
        String classificacao = getClassificacaoImc();
        return "Aluno " + nome + " — IMC: " + String.format("%.1f", getImc()) + " (" + classificacao + ")";
    }

    @Override
    public String getTipo() {
        return "Aluno";
    }

    public int getIdade() {
        if (dataNascimento == null) return 0;
        return Period.between(dataNascimento, LocalDate.now()).getYears();
    }

    public double getImc() {
        if (altura == 0) return 0;
        return peso / (altura * altura);
    }

    public String getClassificacaoImc() {
        double imc = getImc();
        if (imc == 0) return "Não calculado";
        if (imc < 18.5) return "Abaixo do peso";
        else if (imc < 25) return "Peso normal";
        else if (imc < 30) return "Sobrepeso";
        else return "Obesidade";
    }
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getEndereco() { return endereco; }
    public void setEndereco(String endereco) { this.endereco = endereco; }

    public LocalDate getDataNascimento() { return dataNascimento; }
    public void setDataNascimento(LocalDate dataNascimento) { this.dataNascimento = dataNascimento; }

    public double getPeso() { return peso; }
    public void setPeso(double peso) { this.peso = peso; }

    public double getAltura() { return altura; }
    public void setAltura(double altura) { this.altura = altura; }

    public LocalDate getDataCadastro() { return dataCadastro; }
    public void setDataCadastro(LocalDate dataCadastro) { this.dataCadastro = dataCadastro; }

    public boolean isAtivo() { return ativo; }
    public void setAtivo(boolean ativo) { this.ativo = ativo; }
}
