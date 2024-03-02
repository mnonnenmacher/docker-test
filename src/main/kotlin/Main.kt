package org.example

fun main() {
    println("Print versions")
    run("cargo", "--version")
    run("java", "-version")
    run("npm", "--version")
}

private fun run(vararg command: String) {
    runCatching {
        val builder = ProcessBuilder(*command)
        builder.redirectErrorStream(true)
        val process = builder.start()
        val output = process.inputStream.bufferedReader().readText()
        println("\n${command.joinToString()}:\n$output\n")
    }.onFailure {
        println("\nError: ${it.message}\n")
    }
}
