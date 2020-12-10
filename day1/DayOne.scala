import scala.collection.mutable.ListBuffer
import scala.io.Source

object DayOne {
  def main(args: Array[String]): Unit = {
    if (args.length != 1) {
      println("Usage: scala DayOne FILENAME\n")
    } else {
      println("Day 1\n")

      readValues(args(0)) match {
        case Some(values) =>
          println("Part 1")
          processOne(values, 2020) match {
            case Some(duet) =>
              println("Got pair -> " + duet._1 + ", " + duet._2)
              println("Product  -> " + duet._1 * duet._2)
            case None => println("no result")
          }
          println("")

          println("Part 2")
          processTwo(values, 2020) match {
            case Some(triplet) =>
            println("Got triplet -> " + triplet._1 + ", " + triplet._2 + ", " + triplet._3)
            println("Product     -> " + triplet._1 * triplet._2 * triplet._3)
            case None => println("no result")
          }
          println("")
        case None => println("Unable to open " + args(0))
      }
    }
  }

  def readValues(filename: String): Option[Array[Int]] = {
    try {
      val values = ListBuffer[Int]()
      for (line <- Source.fromFile(filename).getLines) {
        values += line.toInt
      }
      Some(values.toArray)
    } catch {
      case e: Exception => None
    }
  }

  def processOne(values: Array[Int], target: Int): Option[(Int, Int)] = {
    for (i <- 0 until values.length - 1; j <- i + 1 until values.length) {
      if (values(i) + values(j) == target) {
        return Some(values(i), values(j))
      }
    }
    None
  }

  def processTwo(values: Array[Int], target: Int): Option[(Int, Int, Int)] = {
    for (i <- 0 until values.length - 1) {
      val temp = split(values, i);
      processOne(temp, target - values(i)) match {
        case Some(duet) => return Some(values(i), duet._1, duet._2)
        case _ => 
      }
    }
    None
  }

  def split(values: Array[Int], pos: Int): Array[Int] = {
    values.slice(0, pos + 1) ++ values.slice(pos + 1, values.length + 1)
  }
}
