package entidades;

public class Instrutor extends Pessoa {

    private int idInstrutor;
    private String especialidade;

    public Instrutor() {
        super();
    }

    public Instrutor(int idInstrutor, String nome, String cpf, String email, String telefone, String especialidade) {
        super(nome, cpf, email, telefone);
        this.idInstrutor = idInstrutor;
        this.especialidade = especialidade;
    }

    @Override
    public String getDescricao() {
        return "Instrutor " + nome + " — Especialidade: " + especialidade;
    }

    @Override
    public String getTipo() {
        return "Instrutor";
    }

    public int getIdInstrutor() { return idInstrutor; }

    public String getEspecialidade() { return especialidade; }
    public void setEspecialidade(String especialidade) { this.especialidade = especialidade; }
}
