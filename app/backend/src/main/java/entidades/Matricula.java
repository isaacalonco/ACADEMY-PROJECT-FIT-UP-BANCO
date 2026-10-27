package entidades;

import java.time.LocalDate;

public class Matricula {

    private int idMatricula;
    private int idAluno;
    private int idPlano;
    private LocalDate dataMatricula;

    public Matricula() {}

    public Matricula(int idMatricula, int idAluno, int idPlano, LocalDate dataMatricula) {
        this.idMatricula = idMatricula;
        this.idAluno = idAluno;
        this.idPlano = idPlano;
        this.dataMatricula = dataMatricula;
    }

    public int getIdMatricula() {
        return idMatricula;
    }

    public int getIdAluno() {
        return idAluno;
    }

    public int getIdPlano() {
        return idPlano;
    }

    public LocalDate getDataMatricula() {
        return dataMatricula;
    }

    public void setIdAluno(int idAluno) {
        this.idAluno = idAluno;
    }

    public void setIdPlano(int idPlano) {
        this.idPlano = idPlano;
    }

    public void setDataMatricula(LocalDate dataMatricula) {
        this.dataMatricula = dataMatricula;
    }

    @Override
    public String toString() {
        return "Matricula{" +
                "idMatricula=" + idMatricula +
                ", idAluno=" + idAluno +
                ", idPlano=" + idPlano +
                ", dataMatricula=" + dataMatricula +
                '}';
    }
}
